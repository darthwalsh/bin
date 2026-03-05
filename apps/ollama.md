
- [x] Tried to run https://ollama.com/library/llama3.3 on macbook and that did not work
https://www.llama.com/docs/llama-everywhere/running-meta-llama-on-mac/
- [x] Tried something smaller ?3.2 ?2 and that seemed to work better
- [ ] Try running model that only needs 4-8GB? need other RAM
- [ ] Try https://github.com/JerryZLiu/Dayflow app using Local LLM, but requires 16GB rRAM?

## Measuring machine for models
Run: https://github.com/AlexsJones/llmfit
- `meta-lLama/Llama-3.3-70B-Instruct` shows Mem Usage: **1589.8%** (115.4 / 7.3 GB)

Claude filtered down the top 100 from `llmfit` by kinds:

| Kind            | Status     | Model                            | Size | Score | tok/s  | Context |
| --------------- | ---------- | -------------------------------- | ---- | ----- | ------ | ------- |
| Coding          | 🟢 Perfect | bigcode/starcoder2-7b            | 7.2B | 89    | 44.1   | 16k     |
| General Purpose | 🟡 Good    | meta-llama/Llama-3.1-8B-Instruct | 8.0B | 89    | 39.4   | 4k      |
| Thinking        | 🟢 Perfect | Qwen/Qwen3-4B-Thinking-2507      | 4.0B | 74    | 78.6   | 262k    |
| Fast            | 🟢 Perfect | Qwen/Qwen2.5-1.5B-Instruct       | 1.5B | 77    | 151.4  | 32k     |
| Embedding       | 🟢 Perfect | nomic-ai/nomic-embed-text-v1.5   | 137M | 72    | 1706.2 | 8k      |
| Math            | 🟢 Perfect | Qwen/Qwen2.5-Math-7B-Instruct    | 7.6B | 89    | 41.5   | 4k      |
| Vision          | 🟢 Perfect | Qwen/Qwen2.5-VL-3B-Instruct      | 3.8B | 79    | 84.2   | 128k    |
| Tiny/Edge       | 🟢 Perfect | Qwen/Qwen2.5-0.5B-Instruct       | 494M | 69    | 473.1  | 32k     |
