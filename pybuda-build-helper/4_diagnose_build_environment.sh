#!/bin/bash
# PyBuda Build Environment Diagnostic Script
# Run this to check if your environment is ready for building from source

HOST_USER="baruch"
HOST_IP="192.168.1.158"
CONTAINER_NAME="tt-e75-dev"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=========================================="
echo "PyBuda Build Environment Diagnostics"
echo -e "==========================================${NC}"
echo ""

# Check 1: Container running
echo -e "${YELLOW}Check 1: Container Status${NC}"
if ssh ${HOST_USER}@${HOST_IP} "docker ps | grep ${CONTAINER_NAME} > /dev/null"; then
    echo -e "${GREEN}✓ Container ${CONTAINER_NAME} is running${NC}"
else
    echo -e "${RED}✗ Container ${CONTAINER_NAME} is not running${NC}"
    exit 1
fi
echo ""

# Check 2: Python version
echo -e "${YELLOW}Check 2: Python Version${NC}"
ssh ${HOST_USER}@${HOST_IP} "docker exec ${CONTAINER_NAME} python --version"
echo ""

# Check 3: GCC version
echo -e "${YELLOW}Check 3: C++ Compiler${NC}"
ssh ${HOST_USER}@${HOST_IP} "docker exec ${CONTAINER_NAME} g++ --version | head -1"
echo ""

# Check 4: CMake
echo -e "${YELLOW}Check 4: CMake${NC}"
if ssh ${HOST_USER}@${HOST_IP} "docker exec ${CONTAINER_NAME} which cmake > /dev/null 2>&1"; then
    ssh ${HOST_USER}@${HOST_IP} "docker exec ${CONTAINER_NAME} cmake --version | head -1"
    echo -e "${GREEN}✓ CMake available${NC}"
else
    echo -e "${YELLOW}⚠ CMake not found (may need to install)${NC}"
fi
echo ""

# Check 5: Required libraries
echo -e "${YELLOW}Check 5: Required Libraries${NC}"

echo -n "  yaml-cpp: "
if ssh ${HOST_USER}@${HOST_IP} "docker exec ${CONTAINER_NAME} ldconfig -p | grep yaml-cpp > /dev/null"; then
    VERSION=$(ssh ${HOST_USER}@${HOST_IP} "docker exec ${CONTAINER_NAME} ldconfig -p | grep yaml-cpp | head -1 | grep -oP 'libyaml-cpp\.so\.\K[0-9.]+'" || echo "unknown")
    echo -e "${GREEN}✓ Found (version ${VERSION})${NC}"
else
    echo -e "${RED}✗ Not found${NC}"
fi

echo -n "  boost: "
if ssh ${HOST_USER}@${HOST_IP} "docker exec ${CONTAINER_NAME} ldconfig -p | grep boost_system > /dev/null"; then
    VERSION=$(ssh ${HOST_USER}@${HOST_IP} "docker exec ${CONTAINER_NAME} ldconfig -p | grep boost_system | head -1 | grep -oP 'libboost_system\.so\.\K[0-9.]+'" || echo "unknown")
    echo -e "${GREEN}✓ Found (version ${VERSION})${NC}"
else
    echo -e "${RED}✗ Not found${NC}"
fi
echo ""

# Check 6: Python packages
echo -e "${YELLOW}Check 6: Python Build Tools${NC}"

echo -n "  setuptools: "
if ssh ${HOST_USER}@${HOST_IP} "docker exec ${CONTAINER_NAME} python -c 'import setuptools' 2>/dev/null"; then
    VERSION=$(ssh ${HOST_USER}@${HOST_IP} "docker exec ${CONTAINER_NAME} python -c 'import setuptools; print(setuptools.__version__)' 2>/dev/null")
    echo -e "${GREEN}✓ ${VERSION}${NC}"
else
    echo -e "${RED}✗ Not installed${NC}"
fi

echo -n "  wheel: "
if ssh ${HOST_USER}@${HOST_IP} "docker exec ${CONTAINER_NAME} python -c 'import wheel' 2>/dev/null"; then
    VERSION=$(ssh ${HOST_USER}@${HOST_IP} "docker exec ${CONTAINER_NAME} python -c 'import wheel; print(wheel.__version__)' 2>/dev/null")
    echo -e "${GREEN}✓ ${VERSION}${NC}"
else
    echo -e "${RED}✗ Not installed${NC}"
fi

echo -n "  pybind11: "
if ssh ${HOST_USER}@${HOST_IP} "docker exec ${CONTAINER_NAME} python -c 'import pybind11' 2>/dev/null"; then
    VERSION=$(ssh ${HOST_USER}@${HOST_IP} "docker exec ${CONTAINER_NAME} python -c 'import pybind11; print(pybind11.__version__)' 2>/dev/null")
    echo -e "${GREEN}✓ ${VERSION}${NC}"
else
    echo -e "${YELLOW}⚠ Not installed (will need to install)${NC}"
fi
echo ""

# Check 7: PyTorch
echo -e "${YELLOW}Check 7: PyTorch${NC}"
if ssh ${HOST_USER}@${HOST_IP} "docker exec ${CONTAINER_NAME} python -c 'import torch; print(\"Version:\", torch.__version__)' 2>/dev/null"; then
    echo -e "${GREEN}✓ PyTorch available${NC}"
else
    echo -e "${RED}✗ PyTorch not available${NC}"
fi
echo ""

# Check 8: TensorFlow
echo -e "${YELLOW}Check 8: TensorFlow${NC}"
if ssh ${HOST_USER}@${HOST_IP} "docker exec ${CONTAINER_NAME} python -c 'import tensorflow as tf; print(\"Version:\", tf.__version__)' 2>/dev/null"; then
    echo -e "${GREEN}✓ TensorFlow available${NC}"
else
    echo -e "${RED}✗ TensorFlow not available${NC}"
fi
echo ""

# Check 9: Current PyBuda status
echo -e "${YELLOW}Check 9: Current PyBuda Installation${NC}"
if ssh ${HOST_USER}@${HOST_IP} "docker exec ${CONTAINER_NAME} python -c 'import pybuda; print(\"Version:\", pybuda.__version__)' 2>/dev/null"; then
    echo -e "${YELLOW}⚠ PyBuda already installed (will be replaced by source build)${NC}"
else
    echo -e "${BLUE}ℹ PyBuda not currently installed (expected before build)${NC}"
fi
echo ""

# Check 10: Disk space
echo -e "${YELLOW}Check 10: Disk Space${NC}"
ssh ${HOST_USER}@${HOST_IP} "docker exec ${CONTAINER_NAME} df -h / | tail -1"
echo -e "${BLUE}ℹ Build requires ~2-5GB of free space${NC}"
echo ""

# Check 11: Source code locations
echo -e "${YELLOW}Check 11: Source Code Availability${NC}"
for path in "/host_home/programs/april16tt/tt-buda" \
            "/host_home/programs/tt-test" \
            "/workspace/tt-buda" \
            "/workspace/tt-buda-source"; do
    if ssh ${HOST_USER}@${HOST_IP} "docker exec ${CONTAINER_NAME} test -d $path 2>/dev/null"; then
        echo -e "${GREEN}✓ Found: $path${NC}"
    fi
done
echo ""

# Summary
echo -e "${BLUE}=========================================="
echo "Diagnostic Summary"
echo -e "==========================================${NC}"
echo ""
echo "If all critical checks passed (marked with ✓), you can proceed with:"
echo "  bash 3_build_pybuda_from_source.sh"
echo ""
echo "If you see warnings (⚠) or errors (✗), address them first:"
echo "  - Install missing packages: pip install <package> --break-system-packages"
echo "  - Install missing libraries: apt-get install -y <library>"
echo ""
echo "For detailed build instructions, see:"
echo "  BUILD_FROM_SOURCE_GUIDE.md"
echo ""
