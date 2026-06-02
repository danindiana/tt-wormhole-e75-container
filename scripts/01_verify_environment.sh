#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════════════════════
# 01_verify_environment.sh
# ═════════════════════════════════════════════════════════════════════════════
# Purpose: Verify the Grayskull development environment is properly set up
# Run: bash scripts/01_verify_environment.sh

set -euo pipefail

echo "═══════════════════════════════════════════════════════════════════════"
echo "  Tenstorrent Grayskull e150 Environment Verification"
echo "═══════════════════════════════════════════════════════════════════════"
echo ""

ERRORS=0
WARNINGS=0

# ── Check if we're in a container ────────────────────────────────────────────
echo "[1/10] Checking if running in container..."
if [ -f /.dockerenv ] || grep -q docker /proc/1/cgroup 2>/dev/null; then
    echo "✓ Running inside container"
else
    echo "⚠ Not in container (this is OK if running host-side checks)"
    ((WARNINGS++))
fi
echo ""

# ── Check Python version ─────────────────────────────────────────────────────
echo "[2/10] Checking Python version..."
PYTHON_VER=$(python3 --version 2>&1 | grep -oP '3\.\d+' || echo "unknown")
if [[ "$PYTHON_VER" == "3.10" ]]; then
    echo "✓ Python $PYTHON_VER (correct for legacy PyBuda)"
else
    echo "✗ Python $PYTHON_VER detected (need 3.10 for legacy PyBuda)"
    ((ERRORS++))
fi
echo ""

# ── Check ARCH_NAME environment variable ─────────────────────────────────────
echo "[3/10] Checking ARCH_NAME..."
if [[ "${ARCH_NAME:-}" == "grayskull" ]]; then
    echo "✓ ARCH_NAME=$ARCH_NAME"
else
    echo "✗ ARCH_NAME not set to 'grayskull' (got: ${ARCH_NAME:-unset})"
    ((ERRORS++))
fi
echo ""

# ── Check Tenstorrent devices ────────────────────────────────────────────────
echo "[4/10] Checking Tenstorrent devices..."
if ls /dev/tenstorrent/* >/dev/null 2>&1; then
    DEVICE_COUNT=$(ls -1 /dev/tenstorrent/ | wc -l)
    echo "✓ Found $DEVICE_COUNT Tenstorrent device(s):"
    ls -lh /dev/tenstorrent/
else
    echo "✗ No /dev/tenstorrent/* devices found"
    echo "  Check: lspci -d 1e52:"
    ((ERRORS++))
fi
echo ""

# ── Check build tools ────────────────────────────────────────────────────────
echo "[5/10] Checking build tools..."
TOOLS=("gcc" "g++" "cmake" "ninja" "git" "make")
for tool in "${TOOLS[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        VERSION=$($tool --version 2>&1 | head -1 || echo "unknown")
        echo "  ✓ $tool: $VERSION"
    else
        echo "  ✗ $tool not found"
        ((ERRORS++))
    fi
done
echo ""

# ── Check Python packages ────────────────────────────────────────────────────
echo "[6/10] Checking Python packages..."
PACKAGES=("pytest" "pyyaml" "numpy")
for pkg in "${PACKAGES[@]}"; do
    if python3 -c "import $pkg" 2>/dev/null; then
        echo "  ✓ $pkg installed"
    else
        echo "  ⚠ $pkg not installed (run: make deps)"
        ((WARNINGS++))
    fi
done
echo ""

# ── Check workspace ──────────────────────────────────────────────────────────
echo "[7/10] Checking workspace..."
if [ -f "Makefile" ]; then
    echo "✓ Makefile found"
else
    echo "✗ Makefile not found (run from project root)"
    ((ERRORS++))
fi
if [ -f "Makefile.lock" ]; then
    COMMIT=$(cat Makefile.lock | grep REPO_COMMIT | cut -d= -f2)
    echo "✓ Makefile.lock found (commit: $COMMIT)"
else
    echo "⚠ Makefile.lock not found"
    ((WARNINGS++))
fi
echo ""

# ── Check tt-budabackend repo ────────────────────────────────────────────────
echo "[8/10] Checking tt-budabackend..."
if [ -d "tt-budabackend/.git" ]; then
    cd tt-budabackend
    CURRENT_COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
    echo "✓ tt-budabackend cloned (commit: $CURRENT_COMMIT)"
    cd ..
else
    echo "⚠ tt-budabackend not cloned (run: make clone)"
    ((WARNINGS++))
fi
echo ""

# ── Check build artifacts ────────────────────────────────────────────────────
echo "[9/10] Checking build artifacts..."
if [ -d "tt-budabackend/build" ]; then
    echo "✓ Build directory exists"
    if [ -f "tt-budabackend/build/test/verif/graph_tests/test_graph" ]; then
        echo "✓ test_graph binary found"
    else
        echo "⚠ test_graph not built (run: make tests)"
        ((WARNINGS++))
    fi
else
    echo "⚠ Build directory not found (run: make build_hw)"
    ((WARNINGS++))
fi
echo ""

# ── Check Docker (if on host) ────────────────────────────────────────────────
echo "[10/10] Checking Docker (host-side)..."
if command -v docker >/dev/null 2>&1; then
    if docker ps >/dev/null 2>&1; then
        echo "✓ Docker accessible"
    else
        echo "✗ Docker found but not accessible (permission issue?)"
        ((ERRORS++))
    fi
else
    echo "⚠ Docker not found (OK if in container)"
fi
echo ""

# ── Summary ──────────────────────────────────────────────────────────────────
echo "═══════════════════════════════════════════════════════════════════════"
echo "  Verification Summary"
echo "═══════════════════════════════════════════════════════════════════════"
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo "✅ All checks passed! Environment is ready."
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo "⚠️  $WARNINGS warning(s) found. Review above."
    echo "   Environment is mostly ready but may need setup steps."
    exit 0
else
    echo "❌ $ERRORS error(s) and $WARNINGS warning(s) found."
    echo "   Fix errors before proceeding."
    exit 1
fi
