#!/usr/bin/bash

source /opt/intel/oneapi/setvars.sh
# ~/playgound/llama.cpp/build/bin/llama-server -m ~/.models/Cydonia-24B-v4zg-Q2_K.gguf -mg 1 --repeat-penalty 1.05 --temp 0.8 -mg 1 --ctx-size 5000
#~/playgound/llama.cpp/build/bin/llama-server -m ~/.models/Gemma-The-Writer-Mighty-Sword-9B-D_AU-Q4_k_m.gguf -mg 1 --repeat-penalty 1.05 --temp 0.8 -mg 1 --ctx-size 5000
~/playgound/llama.cpp/build/bin/llama-server -m ~/.models/Qwen3-8B-Q4_K_M.gguf -mg 1 --repeat-penalty 1.05 --temp 0.8 -mg 1 --ctx-size 5000



# ~/build/bin/llama-server -mg 1 --repeat-penalty 1.05 --temp 0.8 -mg 1 --ctx-size 9128 --models-dir ~/.models/ --verbosity 1
