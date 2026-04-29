# Audi Traffic Light Information (TLI) & V2I Ecosystem

#ai-slop

Audi shipped the first consumer traffic-light connected-car features: a countdown to green and a speed advisory to catch the green wave. This is the most publicly documented V2I (Vehicle-to-Infrastructure) deployment in the consumer space as of early 2026.

## What Audi shipped (verified)

Sources: [Audi media release 301](https://media.audiusa.com/en-us/releases/301), [release 412](https://media.audiusa.com/en-us/releases/412), [LA/NY/SF expansion](https://media.audiusa.com/releases/485).

**Traffic Light Information (TLI)** — shows in-dash countdown timer: seconds until the light turns green. Eliminates the guesswork of stale red lights.

**Green Light Optimized Speed Advisory (GLOSA)** — recommends a driving speed (e.g., "slow to 25 mph") to arrive at the intersection as the light goes green, avoiding a full stop. Fuel/energy conservation side benefit.

Both features:
- OEM-integrated (in-dash, not a phone app)
- Require compatible roadside infrastructure — not available at all intersections
- Expanded to 22,000+ intersections across U.S. cities including San Francisco, Los Angeles, New York

## Infrastructure stack (inferred from public sources)

The actual wire protocol between traffic controllers and Audi's cloud is not publicly documented by Audi. The verified pieces:

**Traffic Technology Services (TTS)** powers Audi's feature via their [Personal Signal Assistant](https://www.traffictechservices.com/personalsignalassistant.html) — a commercial V2I Infrastructure-as-a-Service product. TTS aggregates municipal signal data and sells it to OEMs.

The underlying signal data format is likely [SAE J2735](https://www.sae.org/standards/content/j2735_202309/) **SPaT** (Signal Phase and Timing) messages, the U.S. standard for broadcasting traffic light state from roadside units (RSUs). This is **unspecified** by Audi — inferred from industry context.

```
Traffic signal controller
    ↓ NTCIP 1202 (controller protocol)
RSU or city back-office system
    ↓ J2735 SPaT/MAP messages
TTS aggregation service
    ↓ proprietary API
Audi cloud
    ↓
In-car display
```

## Coverage: what's live, what's not (Bay Area focus)

Audi's public coverage list: select U.S. cities. **San Francisco is confirmed**. **Novato / Marin County is not listed** in any public Audi/TTS material found.

California's live SPaT deployments (from [Caltrans CAV projects](https://dot.ca.gov/programs/traffic-operations/cav/projects)):
- **El Camino Real corridor (Palo Alto / Mountain View)** — 31 intersections with connected-vehicle infrastructure generating live SPaT, adaptive signal, and priority timing. Publicly documented.
- Novato / Marin: no public SPaT API, RSU frequency, or connected-signal feed found.

Bay Area 511 open APIs cover traffic incidents and express-lane toll data — not live signal phase timing.

## SPaT data access options (ranked by realism)

1. **Commercial provider (TTS or equivalent)** — only production-grade path found. TTS positions it as commercial IaaS; not an open developer API.
2. **Agency partnership** — ask City of Novato / Marin / Caltrans District 4 for non-public controller or connected-corridor access. Public absence doesn't prove nothing exists.
3. **Radio / RSU** — only if there's a live connected-vehicle deployment nearby. Not verified for Novato.
4. **Inference from repeated observations** — approximate timing, not true live SPaT.

## OSS for SPaT decoding (once you have a source)

The OSS solves decoding; it doesn't solve data access.

**[USDOT j2735decoder](https://github.com/usdot-fhwa-stol/j2735decoder)** — Python library decoding SAE J2735 UPER hex. Supports BSM, MAP, SPaT. Outputs JSON.

**[USDOT V2X-Hub](https://github.com/usdot-fhwa-OPS/V2X-Hub)** — open-source connected-vehicle infrastructure software. Includes a SPAT Plugin that reads a traffic signal controller via NTCIP 1202 and generates J2735 SPaT. Also handles MAP, forwarding, priority. Closest to a reference stack.

## Why building a third-party app is harder than it looks

- **Audi/TTS is not an open API** — it's an OEM service relationship. No public developer portal found.
- **Coverage is intersection-specific** — even where TTS operates, not every intersection is connected.
- **Signal control (not just read) requires municipal buy-in** — requesting a phase change needs legal authorization, safety certification, liability allocation, and fallback behavior for failed comms. No city publicly offers this to consumer apps.
- **Consumer safety/HMI** — showing speed advice while driving requires validation beyond the protocol.

## App idea feasibility map

From the chat that prompted this note — a driver assist app that predicts speed to catch green lights, requests light changes, and scores driving:

| Feature | Needs Spatial Web (HSTP)? | Needs V2I data? | Verdict |
|---|---|---|---|
| Speed advisory to catch green light | Architecture fit; not required | Yes — SPaT or equivalent | Buildable in some cities with commercial data |
| Request light phase change | HSTP governance model fits | Yes + city authorization | Mostly institutional/regulatory barrier, not protocol |
| Driving comfort score (hard stop tracking) | Not needed | No — phone IMU is enough | Straightforward mobile engineering |
| Social kudos / bad-driver reporting | HSTP identity model can help | No | Ordinary backend; dominated by trust & safety problems |

## See also

- [[ieee2874-hyperspace-protocol]] — the Spatial Web standard (HSTP/HSML/UDG) that provides the theoretical architecture
- [[RealtimeMessaging]] — MQTT pub/sub patterns relevant to V2I messaging
