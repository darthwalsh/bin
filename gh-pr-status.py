#!/usr/bin/env uv run
"""Poll GitHub PRs (authored + adopted) and write a status emoji to a file. #ai-slop

Usage:
  gh-pr-status.py            # poll and write status
  gh-pr-status.py add <url>  # add an adopted PR URL to the watch list
  gh-pr-status.py remove <url>  # remove an adopted PR URL from the watch list
  gh-pr-status.py list       # show adopted PRs

Status file: ~/.local/share/gh-pr-status/status.txt
Adopted PRs: ~/.local/share/gh-pr-status/adopted.txt

oh-my-posh segment reads status.txt for ambient display.
"""

# /// script
# dependencies = []
# ///

import argparse
import json
import logging
import os
import re
import subprocess
import sys
from pathlib import Path

DATA_DIR = Path.home() / ".local" / "share" / "gh-pr-status"
STATUS_FILE = DATA_DIR / "status.txt"
ADOPTED_FILE = DATA_DIR / "adopted.txt"

def gh(*args: str, host: str | None = None) -> list[dict]:
    env = os.environ.copy()
    if host:
        env["GH_HOST"] = host
    result = subprocess.run(
        ["gh", *args],
        capture_output=True,
        text=True,
        env=env,
    )
    if result.returncode != 0:
        logging.warning("gh %s failed: %s", " ".join(args), result.stderr.strip())
        return []
    return json.loads(result.stdout)


def classify_pr(pr: dict) -> tuple[bool, bool]:
    """Return (is_approved_ready, is_failing) for a single PR.

    is_approved_ready: approved with all required checks passing (needs manual merge).
    is_failing: has a failing/errored check (not just pending or waiting for review).
    """
    review = pr.get("reviewDecision") or ""
    checks = pr.get("statusCheckRollup") or []
    conclusions = {c.get("conclusion") or c.get("status") for c in checks}

    is_failing = bool(conclusions & {"FAILURE", "ERROR", "TIMED_OUT"})
    ci_passing = not is_failing and not (conclusions & {"IN_PROGRESS", "QUEUED", "PENDING"})
    is_approved_ready = review == "APPROVED" and ci_passing

    return is_approved_ready, is_failing


def fetch_pr_status(number: int, repo: str) -> tuple[bool, bool]:
    """Fetch a single PR's (is_approved_ready, is_failing) via gh pr view."""
    pr = gh(
        "pr", "view", str(number),
        "--repo", repo,
        "--json", "reviewDecision,statusCheckRollup",
    )
    if not pr:
        return False, False
    return classify_pr(pr)


def parse_pr_url(url: str) -> tuple[str, int] | None:
    """Parse 'https://github.com/owner/repo/pull/123' -> ('owner/repo', 123)."""
    m = re.match(r"https?://[^/]+/([^/]+/[^/]+)/pull/(\d+)", url)
    if not m:
        return None
    return m.group(1), int(m.group(2))


def load_adopted() -> list[str]:
    if not ADOPTED_FILE.exists():
        return []
    return [line.strip() for line in ADOPTED_FILE.read_text().splitlines() if line.strip()]


def save_adopted(urls: list[str]) -> None:
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    ADOPTED_FILE.write_text("\n".join(urls) + "\n" if urls else "")


def cmd_add(url: str) -> None:
    if parse_pr_url(url) is None:
        logging.error("Invalid PR URL: %s", url)
        sys.exit(1)
    urls = load_adopted()
    if url in urls:
        logging.info("Already watching: %s", url)
        return
    urls.append(url)
    save_adopted(urls)
    logging.info("Added: %s", url)


def cmd_remove(url: str) -> None:
    urls = load_adopted()
    if url not in urls:
        logging.error("Not in watch list: %s", url)
        sys.exit(1)
    urls.remove(url)
    save_adopted(urls)
    logging.info("Removed: %s", url)


def cmd_list() -> None:
    urls = load_adopted()
    if not urls:
        logging.info("No adopted PRs.")
        return
    for url in urls:
        print(url)


def cmd_poll() -> None:
    approved_ready_url: str | None = None
    failing_url: str | None = None

    def check(pr_url: str, number: int, repo: str) -> None:
        nonlocal approved_ready_url, failing_url
        approved_ready, failing = fetch_pr_status(number, repo)
        logging.debug("%s#%d -> approved_ready=%s failing=%s", repo, number, approved_ready, failing)
        if approved_ready and approved_ready_url is None:
            approved_ready_url = pr_url
        if failing and failing_url is None:
            failing_url = pr_url
        if sys.stdout.isatty():
            symbol = "👌" if approved_ready else "❌" if failing else "  "
            print(symbol, pr["url"])

    own_prs = gh("search", "prs", "--author=@me", "--state=open", "--json", "number,repository,url")
    logging.info("Found %d own PRs", len(own_prs))
    for pr in own_prs:
        check(pr["url"], pr["number"], pr["repository"]["nameWithOwner"])

    for url in load_adopted():
        parsed = parse_pr_url(url)
        if parsed is None:
            logging.warning("Skipping invalid adopted URL: %s", url)
            continue
        check(url, parsed[1], parsed[0])

    if approved_ready_url:
        emoji, link_url = " 👌", approved_ready_url
    elif failing_url:
        emoji, link_url = " ❌", failing_url
    else:
        STATUS_FILE.write_text("")
        logging.info("Wrote empty status to %s", STATUS_FILE)
        return

    # OSC 8 escaped link https://gist.github.com/egmontkob/eb114294efbcd5adb1944c9f3cb5feda
    content = f"\033]8;;{link_url}\033\\{emoji}\033]8;;\033\\"
    STATUS_FILE.write_text(content)
    logging.info("Wrote %r linking to %s in %s", emoji, link_url, STATUS_FILE)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--loglevel", default="info", help="Logging level, e.g. --loglevel debug (default: info)")
    subparsers = parser.add_subparsers(dest="command")
    subparsers.add_parser("poll", help="Poll PRs and write status (default)")
    add_parser = subparsers.add_parser("add", help="Add an adopted PR URL to the watch list")
    add_parser.add_argument("url")
    remove_parser = subparsers.add_parser("remove", help="Remove an adopted PR URL from the watch list")
    remove_parser.add_argument("url")
    subparsers.add_parser("list", help="Show adopted PRs")

    args = parser.parse_args()
    logging.basicConfig(format="[%(asctime)s] {%(filename)s:%(lineno)d} %(levelname)s - %(message)s", level=args.loglevel.upper())

    if args.command is None or args.command == "poll":
        DATA_DIR.mkdir(parents=True, exist_ok=True)
        STATUS_FILE.write_text(" ⏳")
        cmd_poll()
    elif args.command == "add":
        cmd_add(args.url)
    elif args.command == "remove":
        cmd_remove(args.url)
    elif args.command == "list":
        cmd_list()


if __name__ == "__main__":
    main()
