#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════════════════════
# 02_first_build.sh
# ═════════════════════════════════════════════════════════════════════════════
# Purpose: Run the complete first-time build workflow
# Run: bash scripts/02_first_build.sh

set -euo pipefail

echo "═══════════════════════════════════════════════════════════════════════"
echo "  Tenstorrent Grayskull e150 First Build Workflow"
echo "═══════════════════════════════════════════════════════════════════════"
echo ""
echo "This script will:"
echo "  1. Install Python dependencies"
echo "  2. Clone tt-budabackend at pinned commit"
echo "  3. Build hardware-enabled backend"
echo "  4. Build test binaries"
echo "  5. Run simulation smoke test"
echo ""
read -p "Press Enter to continue or Ctrl+C to abort..."
echo ""

# ── Step 1: Dependencies ─────────────────────────────────────────────────────
echo "─────────────────────────────────────────────────────────────────────"
echo "[1/5] Installing Python dependencies..."
echo "─────────────────────────────────────────────────────────────────────"
make deps
echo "✓ Dependencies installed"
echo ""

# ── Step 2: Clone ────────────────────────────────────────────────────────────
echo "─────────────────────────────────────────────────────────────────────"
echo "[2/5] Cloning tt-budabackend..."
echo "─────────────────────────────────────────────────────────────────────"
make clone
make lock-check
echo "✓ Repository cloned and verified"
echo ""

# ── Step 3: Build Hardware ───────────────────────────────────────────────────
echo "─────────────────────────────────────────────────────────────────────"
echo "[3/5] Building hardware-enabled backend..."
echo "─────────────────────────────────────────────────────────────────────"
echo "⏱️  This may take 5-10 minutes..."
make build_hw
echo "✓ Hardware build complete"
echo ""

# ── Step 4: Build Tests ──────────────────────────────────────────────────────
echo "─────────────────────────────────────────────────────────────────────"
echo "[4/5] Building test binaries..."
echo "─────────────────────────────────────────────────────────────────────"
make tests
echo "✓ Test binaries built"
echo ""

# ── Step 5: Smoke Test ───────────────────────────────────────────────────────
echo "─────────────────────────────────────────────────────────────────────"
echo "[5/5] Running simulation smoke test..."
echo "─────────────────────────────────────────────────────────────────────"
make smoke-sim
echo "✓ Simulation test passed"
echo ""

# ── Summary ──────────────────────────────────────────────────────────────────
echo "═══════════════════════════════════════════════════════════════════════"
echo "  ✅ First Build Complete!"
echo "═══════════════════════════════════════════════════════════════════════"
echo ""
echo "Next steps:"
echo "  • Run silicon test:    make smoke-silicon"
echo "  • View all targets:    make help"
echo "  • Clean rebuild:       bash scripts/04_clean_rebuild.sh"
echo ""
echo "Build artifacts:"
echo "  • Backend:  tt-budabackend/build/"
echo "  • Tests:    tt-budabackend/build/test/verif/graph_tests/"
echo ""
