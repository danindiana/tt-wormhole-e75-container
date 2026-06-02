# syntax=docker/dockerfile:1
# ─────────────────────────────────────────────────────────────────────────────
# Dockerfile - Tenstorrent Grayskull e150 Legacy Dev Environment
# ─────────────────────────────────────────────────────────────────────────────
# Base: Ubuntu 22.04 with Python 3.10 (legacy PyBuda requirement)
# Purpose: Build and test tt-budabackend for Grayskull (ARCH_NAME=grayskull)
# Note: This is a FROZEN legacy stack; do not upgrade to mainline TT-Forge

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Etc/UTC \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    ARCH_NAME=grayskull \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1

# Base dependencies for building tt-budabackend
RUN apt-get update && apt-get install -y --no-install-recommends \
    git git-lfs ca-certificates curl wget \
    build-essential cmake ninja-build pkg-config \
    python3 python3-venv python3-pip python3-dev \
    libssl-dev libffi-dev libhwloc-dev libyaml-cpp-dev \
    libboost-all-dev \
    libzmq3-dev libczmq-dev \
    pciutils usbutils udev \
    vim less jq rsync && \
    rm -rf /var/lib/apt/lists/*

# Install PyYAML system-wide (needed by build scripts with #!/usr/bin/env python3)
RUN pip3 install pyyaml numpy

# Install ZeroMQ C++ bindings (cppzmq)
RUN cd /tmp && \
    git clone --depth 1 https://github.com/zeromq/cppzmq.git && \
    cd cppzmq && \
    mkdir build && cd build && \
    cmake .. -DCPPZMQ_BUILD_TESTS=OFF && \
    make -j4 install && \
    cd /tmp && rm -rf cppzmq

# Verify Python version (must be 3.10 for legacy PyBuda)
RUN python3 --version | grep -q "3.10" || \
    (echo "ERROR: Python 3.10 required for legacy PyBuda; found $(python3 --version)" && exit 1)

# Create a non-root user (vscode UID/GID typical; adjust if needed)
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=1000
RUN groupadd --gid ${USER_GID} ${USERNAME} \
 && useradd -s /bin/bash --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} \
 && mkdir -p /home/${USERNAME}/.local /home/${USERNAME}/.cache \
 && chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}

# Tenstorrent device group inside container (GID mapped by runtime)
RUN groupadd -g 995 tenstorrent || true && usermod -aG tenstorrent ${USERNAME}

# Switch to non-root user for Python env setup
USER ${USERNAME}
WORKDIR /work

# Python virtual environment for builds and tests
RUN python3 -m venv /home/vscode/.venv \
 && /home/vscode/.venv/bin/pip install --upgrade pip wheel setuptools \
 && /home/vscode/.venv/bin/pip install pytest pyyaml numpy scipy \
 && echo 'source /home/vscode/.venv/bin/activate' >> /home/vscode/.bashrc

# Set environment to auto-activate venv
ENV PATH="/home/vscode/.venv/bin:${PATH}" \
    VIRTUAL_ENV="/home/vscode/.venv"

# Default shell
CMD ["bash", "-l"]
