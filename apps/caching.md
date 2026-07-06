"There are only two hard things in Computer Science: cache invalidation and naming things" ~ [Phil Karlton](https://martinfowler.com/bliki/TwoHardThings.html)

## When to Cache
I'd always [[#todo-my-software preferences|prefer]] not to add complexity.

Caching might be required by an external API limits or terms. In this case, cache the raw API response, optionally without any large fields you don't expect to need.
If you can transform the raw API response into a domain object cheaply; don't cache the domain object. The question of caching the transformed value is orthogonal.
