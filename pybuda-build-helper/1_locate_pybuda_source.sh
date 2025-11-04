#!/bin/bash
# Script to locate PyBuda source code and assess build requirements
# Run this on baruch or worlock

echo "=========================================="
echo "PyBuda Source Location Discovery"
echo "=========================================="
echo ""

# Find tt-buda repositories
echo "1. Looking for tt-buda repositories..."
ssh baruch@192.168.1.158 'find /home/baruch/programs -type d -name "tt-buda" 2>/dev/null'
echo ""

# Check specific known location
echo "2. Checking april16tt/tt-buda structure..."
ssh baruch@192.168.1.158 'ls -la /home/baruch/programs/april16tt/tt-buda/ 2>/dev/null | head -20'
echo ""

# Look for pybuda subdirectories
echo "3. Looking for pybuda subdirectories..."
ssh baruch@192.168.1.158 'find /home/baruch/programs -type d -name "pybuda" 2>/dev/null'
echo ""

# Check for setup.py files
echo "4. Looking for pybuda setup.py files..."
ssh baruch@192.168.1.158 'find /home/baruch/programs -path "*/pybuda/setup.py" 2>/dev/null'
echo ""

# Check for CMakeLists.txt (C++ build)
echo "5. Looking for pybuda CMakeLists.txt..."
ssh baruch@192.168.1.158 'find /home/baruch/programs -path "*/pybuda/CMakeLists.txt" 2>/dev/null'
echo ""

# Check the directory we know about
echo "6. Checking /home/baruch/programs/april16tt/tt-buda/pybuda..."
ssh baruch@192.168.1.158 'ls -la /home/baruch/programs/april16tt/tt-buda/pybuda/ 2>/dev/null | head -30'
echo ""

# Check for build documentation
echo "7. Looking for build documentation..."
ssh baruch@192.168.1.158 'find /home/baruch/programs -path "*/pybuda/README*" -o -path "*/pybuda/BUILD*" 2>/dev/null'
echo ""

echo "=========================================="
echo "Complete! Review the output above."
echo "=========================================="
