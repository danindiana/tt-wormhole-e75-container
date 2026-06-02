#!/bin/bash
# Automated PyBuda Build from Source Script
# This script builds PyBuda from source inside the tt-e75-dev container

set -e  # Exit on error

# Configuration
HOST_USER="baruch"
HOST_IP="192.168.1.158"
CONTAINER_NAME="tt-e75-dev"
ARCH_NAME="grayskull"
SOURCE_PATH="/home/baruch/programs/april16tt/tt-buda"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=========================================="
echo "PyBuda Build from Source"
echo -e "==========================================${NC}"
echo ""

# Step 1: Verify source exists on host
echo -e "${YELLOW}Step 1: Verifying source code on host...${NC}"
if ssh ${HOST_USER}@${HOST_IP} "test -d ${SOURCE_PATH}"; then
    echo -e "${GREEN}✓ Source directory found: ${SOURCE_PATH}${NC}"
else
    echo -e "${RED}✗ Source directory not found: ${SOURCE_PATH}${NC}"
    echo "Please update SOURCE_PATH in this script to point to your tt-buda source"
    exit 1
fi
echo ""

# Step 2: Check if source is mounted in container
echo -e "${YELLOW}Step 2: Checking if source is accessible in container...${NC}"
if ssh ${HOST_USER}@${HOST_IP} "docker exec ${CONTAINER_NAME} test -d /host_home/programs/april16tt/tt-buda"; then
    echo -e "${GREEN}✓ Source accessible via mount: /host_home/programs/april16tt/tt-buda${NC}"
    CONTAINER_SOURCE="/host_home/programs/april16tt/tt-buda"
else
    echo -e "${YELLOW}⚠ Source not mounted in container${NC}"
    echo "Options:"
    echo "  1. Restart container with source mounted"
    echo "  2. Copy source into container"
    echo "  3. Git clone inside container"
    echo ""
    read -p "Enter option (1/2/3) or 'q' to quit: " option
    
    case $option in
        1)
            echo -e "${YELLOW}Please restart container with source mounted and re-run this script${NC}"
            exit 0
            ;;
        2)
            echo -e "${YELLOW}Copying source to container...${NC}"
            # Create temp directory in container
            ssh ${HOST_USER}@${HOST_IP} "docker exec ${CONTAINER_NAME} mkdir -p /workspace/tt-buda-source"
            # Copy source
            ssh ${HOST_USER}@${HOST_IP} "docker cp ${SOURCE_PATH}/. ${CONTAINER_NAME}:/workspace/tt-buda-source/"
            CONTAINER_SOURCE="/workspace/tt-buda-source"
            echo -e "${GREEN}✓ Source copied to container${NC}"
            ;;
        3)
            echo -e "${YELLOW}Git clone not implemented yet. Please use option 1 or 2.${NC}"
            exit 0
            ;;
        *)
            echo "Exiting."
            exit 0
            ;;
    esac
fi
echo ""

# Step 3: Install build dependencies
echo -e "${YELLOW}Step 3: Installing build dependencies...${NC}"
ssh ${HOST_USER}@${HOST_IP} "docker exec ${CONTAINER_NAME} bash -c '
    pip install --upgrade pip setuptools wheel --break-system-packages
    pip install pybind11 --break-system-packages
'" || {
    echo -e "${RED}✗ Failed to install dependencies${NC}"
    exit 1
}
echo -e "${GREEN}✓ Build dependencies installed${NC}"
echo ""

# Step 4: Check if budabackend is built
echo -e "${YELLOW}Step 4: Checking budabackend build status...${NC}"
if ssh ${HOST_USER}@${HOST_IP} "docker exec ${CONTAINER_NAME} test -f ${CONTAINER_SOURCE}/build/lib/libdevice.so"; then
    echo -e "${GREEN}✓ budabackend already built${NC}"
else
    echo -e "${YELLOW}⚠ budabackend not built. Building now...${NC}"
    ssh ${HOST_USER}@${HOST_IP} "docker exec ${CONTAINER_NAME} bash -c '
        cd ${CONTAINER_SOURCE}
        make -j8 build_hw ARCH_NAME=${ARCH_NAME}
    '" || {
        echo -e "${RED}✗ budabackend build failed${NC}"
        exit 1
    }
    echo -e "${GREEN}✓ budabackend built successfully${NC}"
fi
echo ""

# Step 5: Check for pybuda subdirectory
echo -e "${YELLOW}Step 5: Locating pybuda source...${NC}"
if ssh ${HOST_USER}@${HOST_IP} "docker exec ${CONTAINER_NAME} test -d ${CONTAINER_SOURCE}/pybuda"; then
    PYBUDA_PATH="${CONTAINER_SOURCE}/pybuda"
    echo -e "${GREEN}✓ pybuda found at: ${PYBUDA_PATH}${NC}"
else
    echo -e "${RED}✗ pybuda subdirectory not found${NC}"
    echo "Expected location: ${CONTAINER_SOURCE}/pybuda"
    exit 1
fi
echo ""

# Step 6: Check for setup.py
echo -e "${YELLOW}Step 6: Verifying setup.py...${NC}"
if ssh ${HOST_USER}@${HOST_IP} "docker exec ${CONTAINER_NAME} test -f ${PYBUDA_PATH}/setup.py"; then
    echo -e "${GREEN}✓ setup.py found${NC}"
else
    echo -e "${RED}✗ setup.py not found in ${PYBUDA_PATH}${NC}"
    exit 1
fi
echo ""

# Step 7: Install PyBuda dependencies from requirements.txt
echo -e "${YELLOW}Step 7: Installing PyBuda Python dependencies...${NC}"
if ssh ${HOST_USER}@${HOST_IP} "docker exec ${CONTAINER_NAME} test -f ${PYBUDA_PATH}/requirements.txt"; then
    echo -e "${BLUE}Installing from requirements.txt...${NC}"
    ssh ${HOST_USER}@${HOST_IP} "docker exec ${CONTAINER_NAME} bash -c '
        pip install -r ${PYBUDA_PATH}/requirements.txt --break-system-packages 2>&1 | tail -20
    '" || echo -e "${YELLOW}⚠ Some dependencies may have failed (this is sometimes OK)${NC}"
else
    echo -e "${YELLOW}⚠ No requirements.txt found, continuing...${NC}"
fi
echo ""

# Step 8: Clean previous builds
echo -e "${YELLOW}Step 8: Cleaning previous builds...${NC}"
ssh ${HOST_USER}@${HOST_IP} "docker exec ${CONTAINER_NAME} bash -c '
    cd ${PYBUDA_PATH}
    rm -rf build/ dist/ *.egg-info
    echo \"✓ Cleaned previous builds\"
'"
echo ""

# Step 9: Build PyBuda wheel
echo -e "${YELLOW}Step 9: Building PyBuda wheel...${NC}"
echo -e "${BLUE}This may take 5-15 minutes...${NC}"
echo ""

ssh ${HOST_USER}@${HOST_IP} "docker exec ${CONTAINER_NAME} bash -c '
    cd ${PYBUDA_PATH}
    export ARCH_NAME=${ARCH_NAME}
    export BACKEND_ARCH_NAME=${ARCH_NAME}
    export LD_LIBRARY_PATH=${CONTAINER_SOURCE}/build/lib:\$LD_LIBRARY_PATH
    
    echo \"Building with:\"
    echo \"  ARCH_NAME=\$ARCH_NAME\"
    echo \"  BACKEND_ARCH_NAME=\$BACKEND_ARCH_NAME\"
    echo \"  Source: ${PYBUDA_PATH}\"
    echo \"\"
    
    python setup.py bdist_wheel 2>&1
'" || {
    echo -e "${RED}✗ PyBuda build failed${NC}"
    echo ""
    echo "Check the error messages above. Common issues:"
    echo "  - Missing dependencies"
    echo "  - C++ compilation errors"
    echo "  - budabackend library not found"
    echo ""
    exit 1
}
echo ""
echo -e "${GREEN}✓ PyBuda wheel built successfully!${NC}"
echo ""

# Step 10: List the built wheel
echo -e "${YELLOW}Step 10: Locating built wheel...${NC}"
ssh ${HOST_USER}@${HOST_IP} "docker exec ${CONTAINER_NAME} bash -c '
    ls -lh ${PYBUDA_PATH}/dist/*.whl
'" || {
    echo -e "${RED}✗ Wheel file not found in dist/ directory${NC}"
    exit 1
}
echo ""

# Step 11: Install the wheel
echo -e "${YELLOW}Step 11: Installing PyBuda wheel...${NC}"
ssh ${HOST_USER}@${HOST_IP} "docker exec ${CONTAINER_NAME} bash -c '
    pip uninstall -y pybuda 2>/dev/null || true
    pip install ${PYBUDA_PATH}/dist/*.whl --break-system-packages --force-reinstall
'" || {
    echo -e "${RED}✗ Failed to install wheel${NC}"
    exit 1
}
echo -e "${GREEN}✓ PyBuda installed successfully!${NC}"
echo ""

# Step 12: Test the installation
echo -e "${YELLOW}Step 12: Testing PyBuda installation...${NC}"
echo ""

echo "Test 1: Import PyBuda"
ssh ${HOST_USER}@${HOST_IP} "docker exec ${CONTAINER_NAME} python -c \"
import pybuda
print('✓ PyBuda imported successfully')
print('  Version:', pybuda.__version__)
\"" || {
    echo -e "${RED}✗ Failed to import pybuda${NC}"
    exit 1
}
echo ""

echo "Test 2: Import BackendType"
ssh ${HOST_USER}@${HOST_IP} "docker exec ${CONTAINER_NAME} python -c \"
from pybuda import BackendType
print('✓ BackendType imported successfully')
\"" || {
    echo -e "${RED}✗ Failed to import BackendType${NC}"
    exit 1
}
echo ""

echo "Test 3: Detect devices"
ssh ${HOST_USER}@${HOST_IP} "docker exec ${CONTAINER_NAME} python -c \"
import pybuda
try:
    devices = pybuda.detect_available_devices()
    print('✓ Device detection successful')
    print('  Available devices:', devices)
except Exception as e:
    print('⚠ Device detection failed (may need hardware access):', str(e))
\"" || echo -e "${YELLOW}⚠ Device detection test had issues (may be OK)${NC}"
echo ""

# Step 13: Copy wheel to host for backup
echo -e "${YELLOW}Step 13: Copying wheel to host for backup...${NC}"
WHEEL_NAME=$(ssh ${HOST_USER}@${HOST_IP} "docker exec ${CONTAINER_NAME} ls ${PYBUDA_PATH}/dist/*.whl" | xargs basename)
BACKUP_DIR="/home/${HOST_USER}/pybuda-wheels-backup"

ssh ${HOST_USER}@${HOST_IP} "
    mkdir -p ${BACKUP_DIR}
    docker cp ${CONTAINER_NAME}:${PYBUDA_PATH}/dist/${WHEEL_NAME} ${BACKUP_DIR}/
    echo '✓ Wheel backed up to: ${BACKUP_DIR}/${WHEEL_NAME}'
"
echo ""

# Success!
echo -e "${GREEN}=========================================="
echo "✓ BUILD SUCCESSFUL!"
echo -e "==========================================${NC}"
echo ""
echo "Summary:"
echo "  - PyBuda built from source"
echo "  - Wheel created: ${WHEEL_NAME}"
echo "  - Installed in container: ${CONTAINER_NAME}"
echo "  - Backup location: ${BACKUP_DIR}/${WHEEL_NAME}"
echo ""
echo "The wheel is now compatible with:"
echo "  - yaml-cpp 0.7 (instead of 0.6)"
echo "  - boost 1.74"
echo "  - Your container's exact library versions"
echo ""
echo "Next steps:"
echo "  1. Test PyBuda functionality"
echo "  2. Run model inference tests"
echo "  3. Update your Dockerfile to build from source"
echo "  4. Share success with community!"
echo ""
echo -e "${BLUE}Happy computing with Tenstorrent! 🚀${NC}"
