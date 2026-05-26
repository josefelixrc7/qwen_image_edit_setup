#!/bin/bash

echo "🚀 Starting ComfyUI + Manager + Qwen Models Setup..."

# -------------------------------
# Step 1: Install system deps
# -------------------------------
echo "🔽 Installing system dependencies..."
apt-get update
apt-get install -y git wget python3 python3-pip

# -------------------------------
# Step 2: Install PyTorch (CUDA 12.9)
# -------------------------------
echo "🔽 Installing PyTorch (CUDA 12.9) - Stable + Nightly..."

pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu129 --no-cache-dir

pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu129 --no-cache-dir

# -------------------------------
# Step 3: Clone ComfyUI (if not exists)
# -------------------------------
COMFYUI_DIR="/mnt/comfyui"

if [ -d "$COMFYUI_DIR" ]; then
    echo "✅ ComfyUI directory already exists. Skipping clone."
else
    echo "🔽 Cloning ComfyUI..."
    git clone https://github.com/Comfy-Org/ComfyUI "$COMFYUI_DIR"
fi

# -------------------------------
# Step 4: Install ComfyUI requirements
# -------------------------------
echo "🔽 Installing ComfyUI Python requirements..."
cd "$COMFYUI_DIR" || exit 1
pip install -r requirements.txt

# -------------------------------
# Step 5: Install ComfyUI-Manager
# -------------------------------
MANAGER_DIR="$COMFYUI_DIR/custom_nodes/comfyui-manager"

if [ -d "$MANAGER_DIR" ]; then
    echo "✅ ComfyUI-Manager already installed. Skipping."
else
    echo "🔽 Installing ComfyUI-Manager..."
    mkdir -p "$COMFYUI_DIR/custom_nodes"
    cd "$COMFYUI_DIR/custom_nodes" || exit 1
    git clone https://github.com/ltdrdata/ComfyUI-Manager comfyui-manager
fi

# -------------------------------
# Step 6: Create model directories
# -------------------------------
mkdir -p "$COMFYUI_DIR/models/diffusion_models"
mkdir -p "$COMFYUI_DIR/models/upscale_models"
mkdir -p "$COMFYUI_DIR/models/loras"
mkdir -p "$COMFYUI_DIR/models/vae"
mkdir -p "$COMFYUI_DIR/models/text_encoders"

# -------------------------------
# Step 7: Download Qwen-Image models (if missing)
# -------------------------------
download_if_missing() {
    local filepath="$1"
    local url="$2"
    local filename=$(basename "$filepath")

    if [ -f "$filepath" ]; then
        echo "✅ Already exists: $filename"
    else
        echo "⏬ Downloading: $filename"
        wget -O "$filepath" "$url"
        if [ $? -eq 0 ]; then
            echo "✅ Success: $filename"
        else
            echo "❌ Failed to download: $url"
            return 1
        fi
    fi
}

echo "🔽 Checking and downloading Qwen-Image models..."

# Qwen Image Edit Diffusion Model
download_if_missing "$COMFYUI_DIR/models/diffusion_models/qwen_image_edit_2511_fp8mixed.safetensors" \
    "https://huggingface.co/Comfy-Org/Qwen-Image-Edit_ComfyUI/resolve/main/split_files/diffusion_models/qwen_image_edit_2511_fp8mixed.safetensors"

# Qwen Image Lightning Lora
download_if_missing "$COMFYUI_DIR/models/loras/Qwen-Image-Lightning-4steps-V1.0.safetensors" \
    "https://huggingface.co/lightx2v/Qwen-Image-Lightning/resolve/main/Qwen-Image-Lightning-4steps-V1.0.safetensors"

# Qwen Image VAE
download_if_missing "$COMFYUI_DIR/models/vae/qwen_image_vae.safetensors" \
    "https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/vae/qwen_image_vae.safetensors"

# Qwen Image Text Encoder
download_if_missing "$COMFYUI_DIR/models/text_encoders/qwen_2.5_vl_7b_fp8_scaled.safetensors" \
    "https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/text_encoders/qwen_2.5_vl_7b_fp8_scaled.safetensors"

# Upscaler
download_if_missing "$COMFYUI_DIR/models/upscale_models/4x_foolhardy_Remacri.pth" \
    "https://huggingface.co/FacehugmanIII/4x_foolhardy_Remacri/resolve/main/4x_foolhardy_Remacri.pth"

# -------------------------------
# Final Message
# -------------------------------
echo "🎉 Setup Complete!"
echo "📍 ComfyUI is ready at: $COMFYUI_DIR"
echo "🔹 Start it with: python main.py"
echo "🔹 Access UI: http://localhost:8188"
echo "💡 ComfyUI-Manager is installed. Open the UI and reload to see the tab."
