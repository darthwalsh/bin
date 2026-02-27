#ai-slop
# Realtime Messaging & Event Storage

## Problem / Context
When building realtime applications, especially in the browser, developers often conflate **Message Delivery** (Pub/Sub) with **State Persistence** (Databases). Understanding the spectrum between these two is critical for [[Event Sourcing]]—a pattern where the state of an application is determined by replaying a sequence of events from the beginning of time.

The core confusion often stems from systems that **collapse "storage + pub/sub" into a single abstraction**.

---

## The Core Abstractions: Storage vs. Delivery

The fundamental difference lies in whether the system treats an event as **State** (to be kept) or **Traffic** (to be delivered).

### 1. Storage-Centric (Database Log)
In this model, the "subscription" is actually just a **live query** over stored facts.
- **Mental Model**: "The database is the source of truth. Subscribing is just tailing the log."
- **Replay**: Deterministic and complete. You can always ask for "events 0 to N".
- **Pattern**: **One-to-Many / Replayable**. One producer, many consumers. Messages stay in the topic indefinitely.
- **Fit for [[Event Sourcing]]**: **Excellent**. New clients can join "a day late" and reconstruct the entire state.
- **Examples**: 
    - **[[RealtimeDB|Google Firebase]]**: Indefinite persistence; queries can be turned into realtime snapshots.
    - **Supabase**: Postgres tables with realtime row-level change notifications.

### 2. Delivery-Centric (Pub/Sub & Queues)
In this model, the primary goal is moving data from point A to point B. Persistence is often a secondary "convenience."
- **Mental Model**: "Messages exist to be delivered. If you weren't listening, you might have missed it."
- **Replay**: Usually time-bounded or limited to a "history" buffer.
- **Pattern**: **One-to-One (Queue)** or **One-to-Many (Pub/Sub)**.
    - **Message Queues**: One producer, one consumer. Once processed, the message is removed.
- **Fit for [[Event Sourcing]]**: **Poor**. You cannot have multiple clients replay the same queue from the start.
- **Examples**:
    - **Ably / Pusher**: Optimized for high fan-out and low latency; history is a feature, not the core contract.
    - **RabbitMQ**: Traditional message queue; once a message is acknowledged, it's typically gone.

---

## Cursor Control: Who owns the "Pointer"?

A **cursor** is the marker of the last event a consumer saw. The "Authority" over this pointer defines the system's flexibility.

| Feature | Client-Defined Cursor | Broker-Defined Cursor |
| :--- | :--- | :--- |
| **Ownership** | The Client (Browser/App) | The Server (Broker) |
| **Logic** | "Give me everything after ID `xyz`" | "Give me the next message for Group `A`" |
| **Replay** | Arbitrary (Reset to 0 anytime) | Policy-driven (Limited by retention) |
| **Implementation** | Often an opaque Base64 token or Integer | Internal offsets managed by the service |

Even if a cursor is opaque (e.g. an **encrypted Base64 blob**), preventing "pointer arithmetic", it is still **Client-Defined** if the client is responsible for storing it and presenting it to the service to resume.

---

## Hobbyist Implementation: The Authoritative Log (Fly.io)

If you move away from "browser-only, zero-server" and host a small VM (e.g., on [[hosting.fly|Fly.io]]), you can implement a highly robust event-sourced system using standard tools.

### The Pragmatic Game Server Pattern
Instead of running complex game logic on the server, the server acts as a **minimal authoritative append-only log**.

- **Mental Model**: "The server is a referee that only cares about the order of events and basic rules (e.g., turn enforcement)."
- **Storage**: Use **Postgres** or **SQLite**. A single `game_events` table with `id`, `game_id`, `player_id`, and a `payload` JSON blob is often enough.
- **Protocol**: 
    - **HTTP POST** for submitting moves (intents).
    - **WebSockets or SSE** for clients to "tail" the log and receive updates.
- **Late Joiners**: The server simply streams the entire history from the database to the new client, which replays the logic in the browser to reconstruct the current game state.

### Why this works for Hobbyists
- **Low Overhead**: One VM, one database, no complex message brokers like Kafka.
- **Easy Debugging**: `SELECT * FROM game_events` gives you the entire history of a game in human-readable form.
- **Trust**: The server provides a single, authoritative order of events, preventing race conditions between players.
