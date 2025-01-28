---
tags: app-idea
created: 2017-10-04
---
This is to solve the problem of having terrible WiFi network quality when walking far away from your WiFi router.

1. When WiFi requests are hanging
2. Some system app or kernel module polls TCP queries over WiFi and Mobile data
3. Turn off WiFi
4. Keep polling WiFi and/or location, and re-enable WiFi if it comes back online

---

Also, prevent HTTP connections from dying when switching network from Wifi to mobile data?
Tee existing requests to save unconfirmed TCP packets.
Then when the WiFi TCP connection hangs, the kernel would resume sending packets
*probably an unsolvable problem...*

## Pushed this into ChatGPT
Response sounds very helpful:
> The concept you're describing aligns with **TCP connection persistence** or **seamless network handoff**. This idea involves keeping ongoing TCP connections alive during a network switch (e.g., from Wi-Fi to mobile data) without breaking the session.
> 
> Here’s a breakdown of the core ideas you mentioned:
> 
> 1. **Prevent HTTP Connections from Dying**: This falls under **seamless mobility in networking**, aiming to maintain active connections across network transitions.
> 2. **Tee Existing Requests**: This is like **packet duplication or redundancy**, where unconfirmed TCP packets are saved and potentially re-sent if the original connection fails.
> 3. **Resume Sending Packets**: This relates to **session continuity** — ensuring the TCP stack can resume where it left off when the network changes.
> ### Why It’s Challenging
> This is considered a complex problem because of TCP's design:
> - TCP connections are tied to specific source and destination IP addresses and ports. Switching networks changes the IP, invalidating the connection.
> - Retransmission and buffering are managed by the kernel and assume a stable connection.
> ### Approaches to Solve It
> 
> 1. **MPTCP (Multipath TCP)**:
>     - Allows a single TCP connection to span multiple network paths (e.g., Wi-Fi and mobile data).
>     - Packets can switch between networks without breaking the connection.
> 2. **QUIC (HTTP/3)**:
>     - Designed to handle network changes more gracefully than TCP.
>     - Tied to connection IDs instead of IP addresses, enabling seamless handoffs.
> 3. **Session Resumption**:
>     - For HTTPS, protocols like TLS session resumption or QUIC's mechanisms can help reconnect quickly without re-establishing a full handshake.
> 4. **Application-Level Solutions**:
>     - Implementing retries and reconnection logic at the application level to recover gracefully from network changes.
> 