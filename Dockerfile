# Base image with CUDA 12.6
FROM nvidia/cuda:12.6.0-base-ubuntu22.04

# Install pip, git, and python3-venv
RUN apt-get update -y && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:ubuntu-toolchain-r/test && \
    apt-get update -y && \
    apt-get install -y \
    python3-pip \
    python3-dev \
    python3-venv \
    git \
    build-essential \
    gcc-11 \
    g++-11 \
    libstdc++6

# Create Python/pip aliases, force overwrite if they exist
RUN ln -sf /usr/bin/python3 /usr/bin/python && \
    ln -sf /usr/bin/pip3 /usr/bin/pip

# Create app directory
WORKDIR /app

# Clone the repositories following the instructions
RUN git clone https://github.com/hiyazakite/fluxgym.git --recurse-submodules

# Create and activate virtual environment inside fluxgym directory
RUN cd /app/fluxgym && \
    python -m venv env && \
    . env/bin/activate && \
    cd sd-scripts && \
    pip install --no-cache-dir -r requirements.txt && \
    cd .. && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir "triton==2.2.0" && \
    pip install --upgrade bitsandbytes==0.45.3

# Create directories and symlinks for external mounts
RUN mkdir -p /outputs /datasets /models && \
    cd /app/fluxgym && \
    rm -rf outputs datasets models && \
    ln -s /outputs outputs && \
    ln -s /datasets datasets && \
    ln -s /models models

# Expose port for Gradio
EXPOSE 7860

# Set Gradio to listen on all interfaces
ENV GRADIO_SERVER_NAME="0.0.0.0"

# Set working directory
WORKDIR /app/fluxgym

# Set up virtual environment activation for CMD
ENV VIRTUAL_ENV="/app/fluxgym/env"
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Run the application
CMD ["python", "./app.py"]