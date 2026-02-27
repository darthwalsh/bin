- [ ] Bring in chatgpt threads about environment

Software Stack is a great way to think about your abstractions.

## Start with right stack

[High-level is the goal (but why?) - YouTube](https://www.youtube.com/watch?v=AmrBpxAtPrI) mentioned Simone Giertz's [Truckla](https://www.youtube.com/watch?v=R35gWBtLCYg):
>And just like how if you start with a sedan and try to turn it into a truck, you get a bad truck. If you start with the wrong stack for your software, you're going to get bad software no matter how much effort you put into it.

Every app is a stack of choices, one per layer. You might think React is the default today, but you had alternatives at every level:
- **UI:** React+Redux — not Vue / Svelte / SolidJS / jQuery
- **Platform:** [[browser]] + HTML/CSS/JS — not WebGL / Qt / Game engine
- **Host:** Docker+Linux — not macOS / Windows
- **Hardware:** CPU & Memory

## Component Layers
#ai-slop 

Each layer has a distinct job. Mixing concerns (e.g. letting your build tool decide your hosting, or your app framework serve production traffic) is where coupling sneaks in.

### 1. Hosting / Cloud Platform

Where compute runs and who manages the server lifecycle, scaling, and billing. The choice here determines deployment workflow — push a [[docker]] image, deploy a serverless function, or git-push to a PaaS. Managed platforms (Vercel, fly.io) abstract away the OS entirely; raw cloud (AWS EC2, DigitalOcean droplets) gives full control but you own uptime. Containers sit between these — they package app + OS into a portable unit that runs the same locally and in production. Interfaces with the web server above and CI/CD pipelines.

See [[webapp.hosting]]

AWS (EC2, Lambda, API Gateway), GCP, Azure, fly.io, Heroku, Render, Railway, Vercel, Netlify, DigitalOcean, Oracle Cloud

### 2. Web Server / Reverse Proxy

Accepts TCP connections, terminates TLS, load balances, and routes HTTP to the app server. In production this is distinct from the app framework — Flask's built-in server and Node's `http.listen()` are not meant for real traffic. Many modern tools combine roles: web server + reverse proxy + TLS terminator + load balancer in one binary. Edge gateways (Cloudflare Workers) push this layer closer to the user geographically. Servlet containers like Tomcat play this role in the Java ecosystem.

See [[web.servers]]

Apache, Nginx, Caddy, Traefik, HAProxy, IIS, Tomcat, Cloudflare Workers

### 3. Runtime & Language

The engine that executes backend code, determining what frameworks and libraries are available. Performance profiles vary widely — PHP rebuilds state per request, Node.js uses a single-threaded event loop, Go and Rust compile to native binaries. TypeScript adds static types on top of JavaScript runtimes (Node.js, Bun, Deno). The trend is toward faster runtimes: Bun reimplements Node.js APIs in Zig for raw speed. Interfaces with the OS/container below and the app framework above.

PHP, Python, Ruby, Java, C#/.NET, JavaScript, TypeScript, Node.js, Bun, Deno, Go, Rust, Elixir

### 4. App Server Framework

Provides routing, middleware, request/response handling, and project structure for backend code. "Batteries-included" frameworks (Django, Rails, ASP.NET) ship with ORM, auth, and admin panels; micro-frameworks (Flask, Express, Hono) give a blank slate. Meta-frameworks (Next.js, Nuxt, SvelteKit) blur the line between backend and frontend by handling both server rendering and client routing. Server-side extensions like Livewire (Laravel) and LiveView (Phoenix) keep interactive logic on the server without shipping JS. The framework is the strongest lock-in in the stack — migrations are rewrites.

**Micro:** Flask, Express, Fastify, Hono, Elysia, Sinatra
**Batteries-included:** Django, Rails, Laravel, Spring, ASP.NET Core, Phoenix
**Meta-framework:** Next.js, Nuxt, SvelteKit, Astro
**Server-side interactivity:** Livewire, LiveView, Blazor (C# via WASM)

### 5. API & Data Contract

The interface between frontend and backend — what the client is allowed to ask for and how. REST is the default; GraphQL lets clients request exactly what they need; gRPC uses binary Protobuf for service-to-service speed. tRPC skips the serialization layer entirely by sharing TypeScript types between client and server. WebSockets enable bidirectional real-time communication. This layer changes how frontend code is written — a REST app looks different from a GraphQL app.

REST, GraphQL, gRPC, tRPC, WebSockets

### 6. Database & Services

Persistent storage and backend infrastructure that outlives any single request. The database is the primary choice (Postgres vs. MongoDB fundamentally changes your data model), but this layer also includes caching, message queues, search engines, and object storage — all stateful services accessed by the framework layer and invisible to the frontend. These are rarely called out in stack names because they're added as scaling concerns, not architectural decisions.

**Relational:** PostgreSQL, MySQL, SQL Server, SQLite, Turso
**Document/NoSQL:** MongoDB, DynamoDB, Firestore, CouchDB
**Caching:** Redis, Memcached
**Message queues:** RabbitMQ, Kafka, AWS SQS
**Search:** Elasticsearch, Algolia
**Object storage:** S3, Minio
**ORM/query builder:** Prisma, Drizzle, SQLAlchemy, Hibernate, ActiveRecord

### 7. UI & Client-Side

Everything that runs in the [[browser]] to produce what the user sees and interacts with. Ranges from full SPA renderers that own all HTML (React, Vue) to "sprinkle" libraries that enhance server-rendered HTML (HTMX, Alpine.js) — the tradeoff is interactivity vs. simplicity. Template engines (Jinja2, Razor) render HTML on the server before it reaches the browser. CSS frameworks (Tailwind, Bootstrap) handle layout and styling without writing custom CSS.

**SPA renderers:** React, Vue, Svelte, Angular, SolidJS
**Server-driven:** HTMX, Turbo/Hotwire
**Sprinkle/lightweight:** Alpine.js, jQuery, Hyperscript
**Template engines:** Jinja2, Razor, EJS, Pug, ERB
**CSS frameworks:** Tailwind, Bootstrap, Shadcn/ui

### 8. Build Tools

Transforms source (TS, JSX, CSS, Markdown) into browser-ready assets and runs the local dev server during development. Invisible to users but dominates developer experience — HMR speed, error overlays, and cold start time are all here. Static site generators (Gatsby, Hugo, Astro) are specialized build tools that also handle content sourcing and routing. The current generation is Rust-based for speed (Vite via Rolldown, Rspack, Farm). Interfaces with the UI framework above and the [[browser]] dev tools.

See [[browser.build-tools]]

**Bundlers:** Vite, Webpack, Rspack/Rsbuild, Parcel, Turbopack, Farm, Bun, esbuild
**Static site generators:** Gatsby, Hugo, Astro, Jekyll

---

## Named Stacks
#ai-slop

Popular named stacks by peak year. These represent **what people explicitly communicate** when describing their stack — not what's inferred or obvious.
If a stack name isn't an acronym, we only list technologies that were part of the community consensus of that era's stack definition.

| Year | Name           | Server      | Runtime               | Framework         | API          | Database   | UI                  | Bonus                 |
| ---- | -------------- | ----------- | --------------------- | ----------------- | ------------ | ---------- | ------------------- | --------------------- |
| 1998 | **LAMP**       | Apache      | PHP                   |                   |              | MySQL      |                     | OS: Linux             |
| 2000 | **WAMP**       | Apache      | PHP                   |                   |              | MySQL      |                     | OS: Windows           |
| 2001 | **WIMP**       | IIS         | PHP                   |                   |              | MySQL      |                     | OS: Windows           |
| 2002 | **MAMP**       | Apache      | PHP                   |                   |              | MySQL      |                     | OS: macOS             |
| 2007 | **LEMP**       | Nginx       | PHP                   |                   |              | MySQL      |                     | *Linux implied below* |
| 2007 | **Rails**      |             | Ruby                  | Rails             |              |            |                     |                       |
| 2008 | **Django**     | Nginx       | Python                | Django            |              |            |                     |                       |
| 2010 | **ASP.NET**    | IIS         | C#                    | ASP.NET MVC       |              | SQL Server |                     |                       |
| 2011 | **Spring**     | Tomcat      | Java                  | Spring            |              | MySQL      |                     |                       |
| 2013 | **MEAN**       |             | Node.js               | Express           |              | MongoDB    | Angular             |                       |
| 2015 | **MERN**       |             | Node.js               | Express           |              | MongoDB    | React               |                       |
| 2016 | **MEVN**       |             | Node.js               | Express           |              | MongoDB    | Vue.js              |                       |
| 2018 | **JAMstack**   |             |                       |                   | APIs \[REST] |            | JavaScript, Markup  |                       |
| 2019 | **PERN**       |             | Node.js               | Express           |              | PostgreSQL | React               |                       |
| 2020 | **Serverless** | API Gateway |                       |                   |              | DynamoDB   |                     | Hosting: AWS Lambda   |
| 2021 | **TALL**       |             |                       | Laravel, Livewire |              |            | Tailwind, Alpine.js |                       |
| 2022 | **T3**         |             | TypeScript \[Node.js] |                   | tRPC         |            | Tailwind            |                       |
| 2023 | **PETAL**      |             | Elixir                | Phoenix, LiveView |              |            | Tailwind, Alpine.js |                       |
| 2024 | **HAM**        |             |                       |                   |              | *any*      | HTMX, Alpine.js     |                       |
| 2025 | **BETH**       |             | Bun                   | Elysia            |              | Turso      | HTMX                |                       |
*Not including Hosting and Build layer, since they are infrequently mentioned*.


My takeaways: 
- Starting 2007, you didn't include "L" in your acronym; everything is hosted on Linux!
- Starting 2013, the UI framework becomes very important
