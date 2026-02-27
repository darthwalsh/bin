I've always been confused, so #ai-slop came up with some examples:

# Functional vs Non-functional Requirements — Examples

## **Functional examples**

| Category                      | Example                                                     |
| ----------------------------- | ----------------------------------------------------------- |
| Auth, identity, access        | Users can sign in with SSO (SAML/OIDC).                     |
| CRUD + domain workflows       | Users can create/read/update/delete projects.               |
| Search, filtering, navigation | Users can search documents by title/content.                |
| UI/UX behavior                | Autosave drafts every 30 seconds.                           |
| APIs and integrations         | Provide webhooks for document.updated events.               |
| Data + reporting              | Generate a monthly usage report per tenant.                 |
| Desktop-specific behaviors    | Work offline and sync changes later.                        |
| Cloud/distributed behaviors   | Multi-tenant isolation: tenant A can’t see tenant B’s data. |

## **Non-functional examples**

| Category                       | Example                                                          |
| ------------------------------ | ---------------------------------------------------------------- |
| Performance & responsiveness   | 95th percentile API latency < 200 ms for read endpoints.         |
| Resource usage                 | Desktop app uses < 500 MB RAM under typical workload.            |
| Scalability & capacity         | Handle 5k requests/second sustained, 10k burst.                  |
| Availability & reliability     | 99.9% monthly uptime for core API.                               |
| Resilience                     | Graceful degradation if a dependency is down (read-only mode).   |
| Data integrity & correctness   | No duplicate records under retry.                                |
| Compliance & governance        | Data residency: EU customers’ data stays in EU region.           |
| Security & privacy             | Encrypt data in transit (TLS 1.2+).                              |
| Maintainability & evolvability | Public APIs are versioned and backward-compatible for 12 months. |
| Compatibility & portability    | Supports latest two versions of Chrome/Edge/Safari.              |
| Operability & observability    | Structured logs include request IDs/correlation IDs.             |
| Usability & accessibility      | WCAG 2.1 AA compliance.                                          |
