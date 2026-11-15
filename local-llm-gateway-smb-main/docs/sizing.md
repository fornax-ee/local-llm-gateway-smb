# Sizing GPU memory

GPU memory holds three things: **model weights**, **KV cache** and runtime overhead.

## Weights

```
weights ≈ parameters × bytes per parameter
```

| Precision | Bytes/param | 8B model | 27B model | 70B model |
|---|---|---|---|---|
| BF16/FP16 | 2 | ~16 GB | ~54 GB | ~140 GB |
| FP8 / INT8 | 1 | ~8 GB | ~27 GB | ~70 GB |
| 4-bit (AWQ/GPTQ) | ~0.5 | ~4–5 GB | ~14–16 GB | ~35–40 GB |

Vision models add a vision encoder (typically a few GB).

## KV cache

Every token in every active request keeps keys and values for every layer:

```
KV bytes per token = 2 × layers × kv_heads × head_dim × bytes per element
```

Example for a typical 8B model with grouped-query attention (32 layers, 8 KV heads, head_dim 128, FP16):

```
2 × 32 × 8 × 128 × 2 bytes = 131 072 bytes ≈ 128 KB per token
32k context  → ~4 GB per full-length request
10 users at full 32k → ~40 GB
```

Read the actual values from the model's `config.json` (`num_hidden_layers`, `num_key_value_heads`, `head_dim` or `hidden_size / num_attention_heads`).

## What eats the KV cache in practice

- **RAG**: retrieved documents are long prompts.
- **Vision**: images become hundreds to thousands of tokens each.
- **Reasoning models**: long hidden "thinking" output.

These three are exactly the shop-floor use cases, which is why a large-memory GPU (e.g. 96 GB class) pays off even for a mid-size model: the extra memory goes to concurrency, not to a bigger model.

## Why cap the context

vLLM reserves KV cache capacity based on `--max-model-len`. Serving a model's full native window (128k+) for a few rare requests reduces how many normal requests fit at once. Cap it (`--max-model-len 32768`) and route long-context work to a profile backed by an external API.

## Rule of thumb

```
GPU memory × 0.9 (gpu-memory-utilization)
  − weights
  − vision encoder / overhead (a few GB)
  = KV cache budget
KV cache budget ÷ (KV per token × typical tokens per request) ≈ concurrent requests
```

Measure with real prompts afterwards; vLLM logs the KV cache capacity at startup.
