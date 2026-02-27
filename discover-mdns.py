#!/usr/bin/env python3
"""
#ai-slop Discover all mDNS-advertised .local hostnames and their IP addresses.

Shows the discovery chain and interesting device identifiers.
Supports running on macOS by parsing the built-in dns-sd (fragile!)

Why not zeroconf? macOS blocks raw multicast sockets from sandboxed processes. dns-sd instead talks to mDNSResponder.
"""

from __future__ import annotations

import argparse
import logging
import socket
import subprocess
from collections.abc import Iterator
from dataclasses import dataclass, field


@dataclass
class ServiceInstance:
  """A discovered service instance with its resolution chain."""

  service_type: str
  instance_name: str
  hostname: str | None = None
  port: int | None = None
  ip_addresses: list[str] = field(default_factory=list)
  txt_records: dict[str, str] = field(default_factory=dict)

  def format_chain(self) -> str:
    """Format the discovery chain showing steps taken."""
    parts = []
    # Start with IP (the result)
    if self.ip_addresses:
      parts.append(self.ip_addresses[0].rjust(15))
    # Then service type discovered
    parts.append(self.service_type)
    # Then instance name found
    parts.append(self.instance_name)
    # Finally the hostname
    if self.hostname:
      parts.append(self.hostname)
    return " > ".join(parts)


class DnsSdClient:
  """Client for dns-sd command-line tool (macOS)."""

  def __init__(self, timeout: float = 2.0):
    self.timeout = timeout

  def _run(self, args: list[str]) -> str:
    """Run dns-sd with timeout and return output."""
    cmd = ["timeout", str(self.timeout), "dns-sd", *args]
    logging.debug(f"Running: {' '.join(cmd)}")
    try:
      result = subprocess.run(
        cmd,
        capture_output=True,
        text=True,
      )
      output = result.stdout + result.stderr
      if result.returncode != 0 and result.stderr:
        logging.debug(f"  Stderr: {result.stderr[:200]}")
      return output
    except FileNotFoundError as e:
      logging.debug(f"  Error: {e}")
      return ""

  def browse_service_types(self) -> Iterator[str]:
    """Browse for all advertised service types."""
    output = self._run(["-B", "_services._dns-sd._udp", "local"])
    for line in output.splitlines():
      if "Add" not in line or "Timestamp" in line:
        continue
      parts = line.split()
      if len(parts) >= 7:
        # Column 6 is protocol (e.g., _tcp.local.), column 7 is service name
        protocol = parts[5].replace(".local.", "")
        service = parts[6]
        yield f"{service}.{protocol}"

  def browse_instances(self, service_type: str) -> Iterator[str]:
    """Browse for instances of a service type."""
    output = self._run(["-B", service_type, "local"])
    for line in output.splitlines():
      if "Add" not in line or "Timestamp" in line:
        continue
      parts = line.split()
      if len(parts) >= 7:
        # Instance name is column 7+ (may contain spaces)
        instance = " ".join(parts[6:])
        yield instance

  def lookup_instance(self, instance: str, service_type: str) -> tuple[str | None, int | None, dict[str, str]]:
    """Look up an instance to get hostname, port, and TXT records."""
    output = self._run(["-L", instance, service_type, "local"])
    hostname = None
    port = None
    txt_records = {}

    for line in output.splitlines():
      if "can be reached at" in line:
        parts = line.split()
        for i, part in enumerate(parts):
          if part == "at" and i + 1 < len(parts):
            host_port = parts[i + 1]
            if ":" in host_port:
              hostname, port_str = host_port.rsplit(":", 1)
              hostname = hostname.rstrip(".")
              try:
                port = int(port_str.rstrip(")"))
              except ValueError:
                pass
            else:
              hostname = host_port.rstrip(".")
            break
      # Parse TXT records (key=value format)
      if "=" in line:
        for part in line.split():
          if "=" in part:
            key, _, value = part.partition("=")
            txt_records[key] = value

    return hostname, port, txt_records

  def resolve_hostname(self, hostname: str) -> list[str]:
    """Resolve a hostname to IP addresses."""
    output = self._run(["-G", "v4", hostname])
    ips = []
    for line in output.splitlines():
      if "Add" in line and "Timestamp" not in line:
        parts = line.split()
        if len(parts) >= 6:
          ip = parts[5]
          if self._is_valid_ip(ip):
            ips.append(ip)
    return ips

  @staticmethod
  def _is_valid_ip(s: str) -> bool:
    """Check if string is a valid IPv4 address."""
    try:
      socket.inet_aton(s)
      return True
    except OSError:
      return False


def discover_all(client: DnsSdClient) -> Iterator[ServiceInstance]:
  """Discover all mDNS service instances with their details."""
  # Get all service types
  service_types = set(client.browse_service_types())
  logging.debug(f"Found {len(service_types)} service types")

  # For each service type, get instances
  seen_hostnames: set[str] = set()

  for svc_type in sorted(service_types):
    logging.debug(f"  Browsing {svc_type}...")

    for instance_name in client.browse_instances(svc_type):
      hostname, port, txt_records = client.lookup_instance(instance_name, svc_type)

      if not hostname or not hostname.endswith(".local"):
        continue

      # Skip duplicates (same hostname from different services)
      if hostname in seen_hostnames:
        continue
      seen_hostnames.add(hostname)

      # Resolve hostname to IP
      ips = client.resolve_hostname(hostname)

      yield ServiceInstance(
        service_type=svc_type,
        instance_name=instance_name,
        hostname=hostname,
        port=port,
        ip_addresses=ips,
        txt_records=txt_records,
      )


def format_output(instance: ServiceInstance) -> str:
  """Format a service instance for display."""
  # Single line showing the discovery chain
  return instance.format_chain()


def main() -> None:
  parser = argparse.ArgumentParser(description="Discover mDNS hostnames and IP addresses")
  parser.add_argument("-v", "--verbose", action="store_true", help="Show progress")
  parser.add_argument("-t", "--timeout", type=float, default=1.0, help="Timeout per operation (default: 1s)")
  args = parser.parse_args()

  # Configure logging format and level
  logging.basicConfig(
    format="%(asctime)s [%(levelname)s] %(message)s",
    level=logging.DEBUG if args.verbose else logging.WARNING,
    datefmt="%Y-%m-%d %H:%M:%S"
  )

  client = DnsSdClient(timeout=args.timeout)
  instances = list(discover_all(client))

  for instance in sorted(instances, key=lambda i: i.hostname or ""):
    print(format_output(instance))


if __name__ == "__main__":
  main()
