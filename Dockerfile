# Use NVIDIA CUDA base image with Python support
FROM nvidia/cuda:12.1.0-cudnn8-devel-ubuntu22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    CUDA_HOME=/usr/local/cuda \
    PATH=/usr/local/bin:$PATH

# Install system dependencies including Python 3.12
RUN apt-get update && apt-get install -y \
    software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa -y \
    && apt-get update && apt-get install -y \
    python3.12 \
    python3.12-venv \
    python3.12-dev \
    curl \
    wget \
    git \
    build-essential \
    libsndfile1 \
    sox \
    libsox-dev \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.12 as default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1 \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3.12 1

# Install pip for Python 3.12 using get-pip.py
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.12

# Upgrade pip
RUN python3.12 -m pip install --upgrade pip setuptools wheel

# Set working directory
WORKDIR /app

# Copy the project files
COPY . /app/

# Install the package and dependencies (skipping FlashAttention for faster build)
RUN pip install -e .

# Expose port for the web UI
EXPOSE 8000

# Set the default command (disabling FlashAttention since it's not installed)
CMD ["qwen-tts-demo", "Qwen/Qwen3-TTS-12Hz-1.7B-CustomVoice", "--ip", "0.0.0.0", "--port", "8000", "--no-flash-attn"]
