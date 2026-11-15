# Profiles

A profile is a stable name for a capability. Applications and users call profiles; the gateway maps them to models.

| Profile | Purpose | Typical backing |
|---|---|---|
| `chat.fast` | everyday Q&A, short answers, assistants at workstations | mid-size instruction model, low latency |
| `chat.reasoning` | multi-step analysis, planning, code | larger or reasoning-tuned model |
| `chat.deep` | rare, heavy tasks | largest available model, or an external API |
| `chat.vision` / `vision.fast` | images: inspection photos, drawings, labels | multimodal model (can share weights with `chat.fast`) |
| `compose.natural` | polished text in a smaller language | language-tuned model |
| `embed.text.v1` | document search (RAG) | embedding model, **version pinned** |
| `rerank.v1` | re-ranking search results | reranker model |

## Rules

- **One multimodal model can serve several profiles.** If the chat model is multimodal, `chat.fast` and `chat.vision` can point to the same deployment and save a full copy of weights.
- **Version in the name when output is persisted.** Embeddings are stored in a vector database, so a model change breaks old vectors. `embed.text.v1` → `embed.text.v2` is a migration, not a config tweak.
- **Profiles have owners and limits.** Each profile has a max context, max output tokens and a rate limit per key. Heavy profiles get lower concurrency.
- **External fallback is a profile too.** `chat.deep` can point to an external API under a business contract. Data class rules decide which keys may use it.

## Why not let clients pick models?

Because then every application hard-codes a model name, and every model upgrade becomes a change request across all applications. With profiles, the upgrade is one line in the gateway config and a test run.
