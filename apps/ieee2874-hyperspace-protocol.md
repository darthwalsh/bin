# IEEE 2874 / Spatial Web: HSTP, HSML, UDG

#ai-slop

[IEEE 2874-2025](https://standards.ieee.org/ieee/2874/11717/) defines an application-layer stack for interoperable cyber-physical systems — devices, robots, sensors, and AI agents exchanging policy-aware, spatially scoped information. The three-part stack mirrors the web:

| Web concept | Spatial Web equivalent | Role |
|---|---|---|
| HTML | **HSML** | Describes entities, relationships, activities, permissions |
| HTTP | **HSTP** | Application-layer transaction protocol between nodes |
| DNS + directory | **UDG** (Universal Description Graph) | Discovery and linking of entities, capabilities, permissions |

The standard is paywalled. Public docs ([IEEE Spectrum](https://spectrum.ieee.org/spatial-web-standard), [SWF intro PDF](https://spatialwebfoundation.org/wp-content/uploads/2024/10/Spatial-Web-Foundation_Specification-Introduction_2024-06-03.pdf)) are strong on architecture, thin on concrete wire-level specs or mature SDKs. Treat all implementation detail below as illustrative.

## Why not just use HTTP

HTTP is designed for **document retrieval**. The Spatial Web addresses problems HTTP doesn't model well:

- Spatial range queries ("what services are within 200m of me?")
- Dynamic, context-aware permissions (ambulance vs. civilian car)
- Machine-readable contracts between heterogeneous agents
- Identity/provenance in multi-party cyber-physical systems
- Policy-aware coordination across IoT, vehicles, drones, infrastructure

Target domains: traffic coordination, smart buildings, drone airspace, emergency dispatch, digital twins.

## Stack position

HSTP sits at the **application layer** over ordinary transports — not a replacement for IP/TCP:

```
L1/L2/L3/L4   Ethernet / Wi-Fi / IP / TCP
               ↑
Transport      Web API (REST) or MQTT
               ↑
HSTP           Semantic transaction layer (operations, identity, spatial scope)
               ↑
HSML           Shared ontology / policy model (entities, activities, permissions)
               ↑
UDG            Discovery / entity graph
```

The public intro explicitly names two HSTP bindings:
- **Web API** (request/response)
- **MQTT** (messaging, better for IoT/vehicle real-time)

## HTTP page load vs. HSTP flow

**Web:** Client wants a resource → sends URL → gets document bytes.

**HSTP:** Agent wants a permitted action in a spatial/time context → sends operation with identity + spatial scope + requested activity → receives allowed/denied + constraints + capabilities.

Concrete flow (from public intro example):
1. Client identifies a domain/node (e.g., an intersection controller)
2. Sends `queryCapabilities` HSTP Operation with spatial scope + identity
3. Response includes supported `activities` (e.g., `querySignalState`, `requestGreenWave`)
4. Client invokes an activity; policy/credential check happens at the node
5. Node returns state, constraints, or acknowledgment

## Conceptual message shape

Not an official wire format — illustrative based on public docs:

```json
{
  "hstpVersion": "0.1-demo",
  "operation": "queryCapabilities",
  "from": "did:example:ambulance-7",
  "to": "did:example:intersection-22",
  "hyperspace": {
    "center": {"lat": 37.77, "lon": -122.42},
    "radiusMeters": 200
  },
  "payload": { "entityType": "traffic-control" }
}
```

Response:
```json
{
  "correlationId": "abc123",
  "status": "ok",
  "payload": {
    "supportedActivities": ["requestGreenWave", "querySignalState"]
  }
}
```

Key fields: identity (`did:`), spatial scope (`hyperspace`), operation semantics (not just a URL path), correlation ID for async.

## Can you run it today?

No official HSTP reference implementation is publicly verifiable as of early 2026. The standard's public material is explicit that deployment is early-stage.

**Best approximation:** implement an HSTP-style envelope over HTTP or MQTT:
1. Model HSML-like entities/activities as JSON
2. Transport over HTTP REST or MQTT topics
3. Add: identity fields, capability discovery, spatial query fields, policy/authorization

MQTT topic convention that fits the model:
- Request: `hstp/domain/intersection-22`
- Reply: `hstp/replies/ambulance-7/{correlationId}`

[GitHub repo for HSML implementation spec](https://github.com/Spatial-Web-Foundation/swf-std-2-HSML-Implementation-specification) exists but is early-stage.

## Practical read

HSTP looks less like "new TCP/IP" and more like:
- A **semantic transaction layer** with identity + policy + spatial scope
- Carried over ordinary transports
- Using a shared ontology
- Aimed at cyber-physical multi-agent coordination

The clearest existing analogy: REST + JSON-LD + OAuth + geofencing — compressed into one coherent standard.

## See also

- [[audi-traffic-light]] — concrete V2I deployment using SPaT/GLOSA
- [[RealtimeMessaging]] — MQTT and pub/sub patterns
- [[web]] — HTTP fundamentals for comparison
