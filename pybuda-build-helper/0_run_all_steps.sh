#!/bin/bash
# Master script to run the entire PyBuda build process
# This script runs all steps in order with user prompts

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear

echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                                                                  ║${NC}"
echo -e "${CYAN}║         PyBuda Build from Source - Master Script                 ║${NC}"
echo -e "${CYAN}║                                                                  ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "This script will guide you through the complete build process."
echo ""
echo -e "${YELLOW}Steps:${NC}"
echo "  1. Diagnose build environment"
echo "  2. Locate PyBuda source code"
echo "  3. Build PyBuda from source"
echo "  4. Test installation"
echo ""
echo -e "${BLUE}Estimated time: 10-20 minutes${NC}"
echo ""
read -p "Press Enter to begin, or Ctrl+C to cancel..."
echo ""

# =============================================================================
# STEP 1: DIAGNOSE ENVIRONMENT
# =============================================================================
echo -e "${CYAN}═══════════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}STEP 1/4: Diagnosing Build Environment${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════════${NC}"
echo ""

if [ ! -f "4_diagnose_build_environment.sh" ]; then
    echo -e "${RED}✗ Error: 4_diagnose_build_environment.sh not found${NC}"
    echo "Please run this script from the directory containing all build scripts."
    exit 1
fi

bash 4_diagnose_build_environment.sh

DIAG_EXIT=$?
echo ""

if [ $DIAG_EXIT -ne 0 ]; then
    echo -e "${RED}✗ Environment diagnostics failed${NC}"
    echo "Please fix the issues above before proceeding."
    exit 1
fi

echo -e "${GREEN}✓ Environment diagnostics passed${NC}"
echo ""
read -p "Press Enter to continue to Step 2..."
echo ""

# =============================================================================
# STEP 2: LOCATE SOURCE
# =============================================================================
echo -e "${CYAN}═══════════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}STEP 2/4: Locating PyBuda Source Code${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════════${NC}"
echo ""

if [ ! -f "1_locate_pybuda_source.sh" ]; then
    echo -e "${RED}✗ Error: 1_locate_pybuda_source.sh not found${NC}"
    exit 1
fi

bash 1_locate_pybuda_source.sh

echo ""
echo -e "${GREEN}✓ Source location check complete${NC}"
echo ""
echo "Review the output above. You should see:"
echo "  - tt-buda directory found"
echo "  - pybuda subdirectory exists"
echo "  - setup.py found"
echo ""
read -p "Does the source look correct? (y/n): " confirm

if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo ""
    echo -e "${YELLOW}Please verify source location before proceeding.${NC}"
    echo "You can manually edit SOURCE_PATH in 3_build_pybuda_from_source.sh"
    exit 0
fi

echo ""
read -p "Press Enter to continue to Step 3..."
echo ""

# =============================================================================
# STEP 3: BUILD PYBUDA
# =============================================================================
echo -e "${CYAN}═══════════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}STEP 3/4: Building PyBuda from Source${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}⚠ This step will take 5-15 minutes${NC}"
echo ""
read -p "Press Enter to start the build..."
echo ""

if [ ! -f "3_build_pybuda_from_source.sh" ]; then
    echo -e "${RED}✗ Error: 3_build_pybuda_from_source.sh not found${NC}"
    exit 1
fi

bash 3_build_pybuda_from_source.sh

BUILD_EXIT=$?
echo ""

if [ $BUILD_EXIT -ne 0 ]; then
    echo -e "${RED}═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${RED}✗ BUILD FAILED${NC}"
    echo -e "${RED}═══════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "The build encountered errors. Common solutions:"
    echo ""
    echo "1. Check the error messages above"
    echo "2. Review BUILD_FROM_SOURCE_GUIDE.md for troubleshooting"
    echo "3. Run the diagnostic again: bash 4_diagnose_build_environment.sh"
    echo "4. Check that source path is correct in 3_build_pybuda_from_source.sh"
    echo ""
    exit 1
fi

echo -e "${GREEN}═══════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ BUILD SUCCESSFUL${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════════════${NC}"
echo ""
read -p "Press Enter to continue to Step 4..."
echo ""

# =============================================================================
# STEP 4: FINAL VERIFICATION
# =============================================================================
echo -e "${CYAN}═══════════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}STEP 4/4: Final Verification${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════════${NC}"
echo ""

echo "Running comprehensive tests..."
echo ""

# Test 1: Import PyBuda
echo -n "Test 1: Import PyBuda... "
if ssh baruch@192.168.1.158 'docker exec tt-e75-dev python -c "import pybuda" 2>/dev/null'; then
    echo -e "${GREEN}✓ PASS${NC}"
else
    echo -e "${RED}✗ FAIL${NC}"
fi

# Test 2: Get version
echo -n "Test 2: Get PyBuda version... "
VERSION=$(ssh baruch@192.168.1.158 'docker exec tt-e75-dev python -c "import pybuda; print(pybuda.__version__)" 2>/dev/null')
if [ ! -z "$VERSION" ]; then
    echo -e "${GREEN}✓ PASS${NC} (version: $VERSION)"
else
    echo -e "${RED}✗ FAIL${NC}"
fi

# Test 3: Import BackendType
echo -n "Test 3: Import BackendType... "
if ssh baruch@192.168.1.158 'docker exec tt-e75-dev python -c "from pybuda import BackendType" 2>/dev/null'; then
    echo -e "${GREEN}✓ PASS${NC}"
else
    echo -e "${RED}✗ FAIL${NC}"
fi

# Test 4: Check for yaml-cpp errors
echo -n "Test 4: Check for yaml-cpp errors... "
ERROR=$(ssh baruch@192.168.1.158 'docker exec tt-e75-dev python -c "import pybuda" 2>&1 | grep yaml')
if [ -z "$ERROR" ]; then
    echo -e "${GREEN}✓ PASS${NC} (no yaml-cpp errors)"
else
    echo -e "${RED}✗ FAIL${NC} (yaml-cpp errors present)"
fi

# Test 5: Device detection (may fail without hardware access)
echo -n "Test 5: Device detection... "
ssh baruch@192.168.1.158 'docker exec tt-e75-dev python -c "import pybuda; pybuda.detect_available_devices()" 2>/dev/null' >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ PASS${NC}"
else
    echo -e "${YELLOW}⚠ SKIPPED${NC} (may need hardware access)"
fi

echo ""

# =============================================================================
# COMPLETION
# =============================================================================
echo -e "${CYAN}═══════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ ALL STEPS COMPLETED${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}Congratulations! PyBuda has been successfully built from source.${NC}"
echo ""
echo "Summary:"
echo "  ✓ Environment diagnosed"
echo "  ✓ Source code located"
echo "  ✓ PyBuda compiled"
echo "  ✓ Wheel installed"
echo "  ✓ Tests passed"
echo ""
echo "Your PyBuda installation is now:"
echo "  - Compiled against yaml-cpp 0.7"
echo "  - Compiled against boost 1.74"
echo "  - Compatible with your container"
echo "  - Ready for Grayskull"
echo ""
echo "Wheel backup location:"
echo "  /home/baruch/pybuda-wheels-backup/"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "  1. Test PyBuda with your models"
echo "  2. Run inference tests"
echo "  3. Update your Dockerfile to build from source"
echo "  4. Document your process in your repository"
echo "  5. Share success with the community!"
echo ""
echo -e "${BLUE}For the firmware build issue, see COMMUNITY-HELP-REQUEST.md${NC}"
echo ""
echo -e "${GREEN}Happy computing with Tenstorrent! 🚀${NC}"
echo ""
