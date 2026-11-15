# Local LLM Gateway for Small and Mid-Size Companies

How to run local AI models for ~50 users on one GPU server, behind a single OpenAI-compatible gateway, with model "profiles" instead of model names.

Written from building and planning such a setup in a manufacturing company: the real use cases were visual quality inspection, production data queries and shop-floor assistants, not general office chat.

## Architecture

```
 users / apps ──► gateway (OpenAI-compatible API, auth, routing, quotas)
                     │
                     ├── chat.fast      ─┐
                     ├── chat.vision    ─┼─► vLLM: multimodal model   (GPU 0)
                     ├── embed.text.v1  ───► vLLM: embedding model    (GPU 0)
                     ├── compose.natural ──► vLLM: language-tuned model
                     └── experiments    ───► vLLM: trials             (GPU 1)
```

- **vLLM** serves the models (OpenAI-compatible API, continuous batching, prefix caching).
- A **gateway** (e.g. LiteLLM proxy, or a thin custom service) gives every client one endpoint, one key per user/app, logging of metadata, and maps **profile names** to the actual models.
- Clients ask for `chat.fast` or `embed.text.v1`, never for a specific model. Models can be swapped without touching any application.

## Contents

| File | What it covers |
|---|---|
| [docs/profiles.md](docs/profiles.md) | Profile design and why clients never name models |
| [docs/sizing.md](docs/sizing.md) | GPU memory: weights + KV cache, how to estimate, why context is capped |
| [docs/decisions.md](docs/decisions.md) | Decisions and lessons: when local AI is worth it and when it is not |
| [config/litellm.yaml](config/litellm.yaml) | Example gateway config |
| [config/vllm.sh](config/vllm.sh) | Example vLLM launch commands |

## Key lessons

1. **Be honest about where local AI wins.** For general writing, document search and compliance text, frontier cloud models under a business contract are usually better. Local models win on data that must not leave the site, on vision at the line, on latency, and on keeping production running when the internet link is down.
2. **Profiles, not model names.** The gateway is the contract; models are an implementation detail.
3. **Pin embedding model versions.** Different embedding models (and versions) produce incompatible vector spaces. Changing one means re-embedding everything. Put the version in the profile name (`embed.text.v1`).
4. **Cap the context length.** Serving the full native context window of a model eats KV cache memory and reduces concurrency. Cap it (e.g. 32k) and send long-context work elsewhere.
5. **Small languages need a dedicated profile.** Mid-size general models often write poor text in smaller languages. A separate `compose.natural` profile backed by a language-tuned model fixes the output without changing the main chat model. Use public language benchmarks to choose.

## License

Docs: CC BY 4.0. Config examples: MIT.

Drafted with AI assistance, based on hands-on experience

More notes and contact: [fornax.ee](https://www.fornax.ee) · Have a similar problem? Write to info@fornax.ee — happy to help.
