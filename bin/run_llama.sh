github/llama.cpp/build/bin/llama-server \
  --models-dir ~/.models \
  --models-max 1 \
  --embedding \
  --ctx-size 96000 \
  --n-gpu-layers 99 \
  --cache-type-k q4_0 \
  --cache-type-v q4_0 \
  --flash-attn on \
  --reasoning on \
  --reasoning-budget 4096 \
  --chat-template-kwargs '{"preserve_thinking":true}' \
  --port 8033 \
  --host 0.0.0.0

# --ctx-size 96000 \

