#!/bin/bash
# Simplified PyBuda Build Script - Non-interactive

set -e

HOST_USER="baruch"
HOST_IP="192.168.1.158"
CONTAINER_NAME="tt-e75-dev"
CONTAINER_SOURCE="/workspace/tt-buda-source"
ARCH_NAME="grayskull"

echo "=========================================="
echo "PyBuda Build from Source (Simplified)"
echo "=========================================="
echo ""

# Step 1: Install build dependencies
echo "Step 1: Installing build dependencies..."
ssh -o PubkeyAuthentication=no ${HOST_USER}@${HOST_IP} "docker exec ${CONTAINER_NAME} bash -c '
    pip install --upgrade pip setuptools wheel
    pip install pybind11
'" && echo "✓ Build dependencies installed" || { echo "✗ Failed"; exit 1; }
echo ""

# Step 2: Set environment and build PyBuda
echo "Step 2: Building PyBuda from source..."
echo "This will take 5-15 minutes..."
ssh -o PubkeyAuthentication=no ${HOST_USER}@${HOST_IP} "docker exec ${CONTAINER_NAME} bash -c '
    cd ${CONTAINER_SOURCE}/pybuda
    
    # Set architecture
    export ARCH_NAME=${ARCH_NAME}
    export BACKEND_ARCH_NAME=${ARCH_NAME}
    export PYTHON_VERSION=3.10
    
    # Clean previous builds
    rm -rf build/ dist/ *.egg-info
    
    # Build wheel
    python3 setup.py bdist_wheel
    
    # Install wheel
    pip install dist/*.whl --force-reinstall
'" && echo "✓ PyBuda built and installed" || { echo "✗ Build failed"; exit 1; }
echo ""

# Step 3: Test installation
echo "Step 3: Testing PyBuda installation..."
ssh -o PubkeyAuthentication=no ${HOST_USER}@${HOST_IP} "docker exec ${CONTAINER_NAME} python3 -c '
import pybuda
print(\"PyBuda version:\", pybuda.__version__)
print(\"✓ Import successful!\")
'" && echo "✓ Test passed" || { echo "✗ Test failed"; exit 1; }
echo ""

echo "=========================================="
echo "✓ PyBuda Build Complete!"
echo "=========================================="
