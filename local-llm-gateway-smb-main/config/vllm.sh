#!/usr/bin/env bash
# Example vLLM launches on one host. Adjust model IDs, ports and memory shares.
# Listen on localhost / private network only; users go through the gateway.
set -euo pipefail

# Main multimodal chat model on GPU 0, context capped at 32k
CUDA_VISIBLE_DEVICES=0 vllm serve "<multimodal-instruct-model>" \
  --host 127.0.0.1 --port 8000 \
  --max-model-len 32768 \
  --gpu-memory-utilization 0.80 \
  --enable-prefix-caching &

# Embedding model on the same GPU, small memory share
# (depending on vLLM version, add --task embed or --runner pooling)
CUDA_VISIBLE_DEVICES=0 vllm serve "<embedding-model>" \
  --host 127.0.0.1 --port 8001 \
  --gpu-memory-utilization 0.10 &

# Language-tuned model for compose.natural on GPU 1
CUDA_VISIBLE_DEVICES=1 vllm serve "<language-tuned-model>" \
  --host 127.0.0.1 --port 8002 \
  --max-model-len 16384 \
  --gpu-memory-utilization 0.85 &

wait
