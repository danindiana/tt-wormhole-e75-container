#!/bin/bash
# Script to analyze PyBuda build requirements
# Run this AFTER locating the source with script 1

PYBUDA_SOURCE="/home/baruch/programs/april16tt/tt-buda"

echo "=========================================="
echo "PyBuda Build Requirements Analysis"
echo "=========================================="
echo ""
echo "Source directory: $PYBUDA_SOURCE"
echo ""

# Check if directory exists
echo "1. Verifying source directory..."
ssh baruch@192.168.1.158 "test -d $PYBUDA_SOURCE && echo '✓ Directory exists' || echo '✗ Directory not found'"
echo ""

# Check for pybuda subdirectory
echo "2. Checking pybuda subdirectory..."
ssh baruch@192.168.1.158 "test -d $PYBUDA_SOURCE/pybuda && echo '✓ pybuda subdirectory exists' || echo '✗ pybuda subdirectory not found'"
echo ""

# Look for setup.py
echo "3. Checking for setup.py..."
ssh baruch@192.168.1.158 "test -f $PYBUDA_SOURCE/pybuda/setup.py && echo '✓ setup.py found' || echo '✗ setup.py not found'"
echo ""

# Look for requirements files
echo "4. Checking for requirements files..."
ssh baruch@192.168.1.158 "ls -la $PYBUDA_SOURCE/pybuda/requirements*.txt 2>/dev/null || echo 'No requirements.txt found'"
echo ""

# Check for Makefile
echo "5. Checking for Makefile..."
ssh baruch@192.168.1.158 "test -f $PYBUDA_SOURCE/Makefile && echo '✓ Makefile found' || echo '✗ Makefile not found'"
echo ""

# Check for build instructions
echo "6. Checking for build documentation..."
ssh baruch@192.168.1.158 "ls -la $PYBUDA_SOURCE/pybuda/README* $PYBUDA_SOURCE/pybuda/docs/BUILD* 2>/dev/null || echo 'No build docs found'"
echo ""

# Check dependencies on budabackend
echo "7. Checking for budabackend dependency..."
ssh baruch@192.168.1.158 "grep -r 'budabackend' $PYBUDA_SOURCE/pybuda/setup.py $PYBUDA_SOURCE/pybuda/CMakeLists.txt 2>/dev/null | head -5"
echo ""

# Check for C++ extensions
echo "8. Looking for C++ extensions..."
ssh baruch@192.168.1.158 "find $PYBUDA_SOURCE/pybuda -name '*.cpp' -o -name '*.cc' -o -name '*.cxx' 2>/dev/null | head -10"
echo ""

# Check for existing build artifacts
echo "9. Checking for existing build artifacts..."
ssh baruch@192.168.1.158 "ls -la $PYBUDA_SOURCE/pybuda/build 2>/dev/null | head -10 || echo 'No build directory'"
echo ""

# Check git status if it's a git repo
echo "10. Checking git status..."
ssh baruch@192.168.1.158 "cd $PYBUDA_SOURCE && git log --oneline -1 2>/dev/null || echo 'Not a git repository'"
echo ""

echo "=========================================="
echo "Analysis complete!"
echo "=========================================="
