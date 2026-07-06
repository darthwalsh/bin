---
aliases:
  - Postgressql
  - psql
---
My top pick for RDMS!
## Replaces Other DBs
From [I replaced my entire stack with Postgres... - The Coding Gopher](https://www.youtube.com/watch?v=TdondBmyNXc):

| Category | Examples | PostgreSQL Replacement |
|---|---|---|
| NoSQL Databases | MongoDB, CouchDB | `JSONB` + `GIN` indexes for querying nested data |
| Message Queues | RabbitMQ, Redis | `SELECT ... FOR UPDATE SKIP LOCKED` for high-concurrency job processing within tables |
| Search Engines | Elasticsearch, Solr | `TSVector` + `TSQuery` for full-text search; `pg_trigram` for fuzzy matching |
| Vector Databases | Pinecone, Weaviate | `pgvector` extension with `HNSW` search alongside relational data |
| Spatial/GIS | PostGIS, ESRI | `PostGIS` extension with `GIST` indexing for geometric queries |
| Time-Series | InfluxDB, TimescaleDB | Declarative partitioning + `BRIN` indexes for log/telemetry storage |
| Data Warehouses | Snowflake, BigQuery | Materialized views with concurrent refreshes for dashboard aggregations |
| API Middleware | Express, FastAPI | `PostgREST` or `pg_graphql` for auto-generated APIs; `RLS` for auth |
