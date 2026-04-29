# MCP (Model Context Protocol)

MCP servers communicate via JSON-RPC: any client can call them directly, no IDE or Cursor needed. ([spec](https://modelcontextprotocol.io/specification/2025-11-25))

## Transports
[Transports](https://modelcontextprotocol.io/specification/2025-03-26/basic/transports):
- **stdio**: client spawns server as subprocess; preferred for local tools
- **Streamable HTTP**: server runs independently, handles multiple clients via HTTP + optional SSE streaming
- **HTTP+SSE**: **deprecated** as of 2025-03-26; replaced by Streamable HTTP

## Primitives
Server-exposed capabilities:
- **Tools**: callable functions the LLM can invoke; may have side effects (write file, run query)
- **Resources**: read-only, URI-addressable data (files, DB rows, API snapshots); client pulls on demand
- **Prompts**: reusable prompt templates / workflows servers expose to clients

Client-exposed capabilities:
- **Sampling**: server asks the client to run LLM inference — server-initiated generation
- **Roots**: client tells server which filesystem roots it has access to
- **Elicitation**: client tells server how to elicit the best response from the LLM

## Calling from a script

Preferred approach: [`mcptools` CLI](https://github.com/f/mcptools)

Wrap the `npx` or `docker run` command:

```pwsh
# List tools a server exposes
mcp tools npx -y @jfim/obsidian-tasks-mcp $vaultPath

# Call the query_tasks tool
$params = @{ query = "not done`nhas due date" } | ConvertTo-Json -Compress
$jsonResult = mcptools call query_tasks `
    --params $params `
    --format json ` # parseable output
    npx -y @jfim/obsidian-tasks-mcp $vaultPath

# Parsing the response
# MCP returns `{ content: [{ text: "..." }] }` — the tool result lives in `.content[0].text`:
$response = $jsonResult | ConvertFrom-Json
if ($response.isError) { throw $response.content[0].text }

$tasks = $response.content[0].text | ConvertFrom-Json
```

See [[due.ps1]] an example.

## Python SDK (alternative)

Official SDK: [github.com/modelcontextprotocol/python-sdk](https://github.com/modelcontextprotocol/python-sdk)
Should be pretty equivalent to the `mcptools` CLI.

See also: [[obsidian-tasks-mcp]]

## Auth
i.e. `Authorization: Bearer <token>` on each MCP JSON-RPC call

Seems to be a problem! [`mcptools`](https://github.com/f/mcptools) can't call HTTP MCP servers with an `Authorization` header — [not yet implemented](https://github.com/f/mcptools/issues/91). Must call the REST endpoint directly (e.g. `httpx` in Python).

## Followups

- [ ] `mcptools` spawns a fresh server process per call — startup cost of `npx` on each invocation (~700ms).

## MCPs I use

- [[smart-connections-mcp]]
- [[obsidian-tasks-mcp]]
