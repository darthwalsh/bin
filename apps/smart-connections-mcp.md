Setup: https://github.com/msdanyg/smart-connections-mcp

`smart-connections-mcp` uses precomputed [[RAG]] embeddings from the Smart Connections Obsidian [[obsidian.plugins]] (`.smart-env/multi/`). 

See [[mcp]] for how to call MCP servers from scripts.

| Tool                      | Behavior                                                            |
| ------------------------- | ------------------------------------------------------------------- |
| `search_notes`            | Given `$query` text searches notes by keyword relevance             |
| `get_similar_notes`       | Given `$note_path` finds similar notes&blocks                       |
| `get_connection_graph`    | Given `$note_path` builds `$depth=2`-level graph of similar notes   |
| `get_embedding_neighbors` | Given `$embedding_vector` finds `$k=10` nearest neighbors           |
| `get_note_content`        | Given `$note_path` returns full content + optional block extraction |
| `get_stats`               | Returns knowledge base statistics (notes, blocks, model)            |

## Known Issue: Long Queries Return No Results
#ai-slop 

The `search_notes` tool fails with complex/long queries even at `threshold: 0`:

```bash
# This returns NO results at any threshold (0, 0.1, 0.5), except THIS file:
export SMART_VAULT_PATH=/Users/walshca/notes
mcptools call search_notes \
  --params '{"query": "speech recognition transcription whisper mlx diarization stereo channels", "threshold": 0.1}' \
  node /Users/walshca/code/smart-connections-mcp/dist/index.js

# But these work with threshold ≤ 0.1:
mcptools call search_notes \
  --params '{"query": "whisper mlx", "threshold": 0.1}' \
  node /Users/walshca/code/smart-connections-mcp/dist/index.js

mcptools call search_notes \
  --params '{"query": "stereo channels", "threshold": 0.1}' \
  node /Users/walshca/code/smart-connections-mcp/dist/index.js
```

**Root cause**: The embedding model (`TaylorAI/bge-micro-v2`) appears to have query length/complexity limits. Multi-concept queries (8+ words spanning different topics) produce embeddings that don't match anything.

**Workaround**: Use 2-4 word focused queries with `threshold: 0.1-0.3`
