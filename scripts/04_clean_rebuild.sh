#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════════════════════
# 04_clean_rebuild.sh
# ═════════════════════════════════════════════════════════════════════════════
# Purpose: Clean and rebuild everything from scratch
# Run: bash scripts/04_clean_rebuild.sh

set -euo pipefail

echo "═══════════════════════════════════════════════════════════════════════"
echo "  Tenstorrent Grayskull e150 Clean Rebuild"
echo "═══════════════════════════════════════════════════════════════════════"
echo ""
echo "⚠️  WARNING: This will delete all build artifacts!"
echo ""
read -p "Are you sure? Type 'yes' to continue: " -r
echo ""

if [[ ! $REPLY =~ ^yes$ ]]; then
    echo "Aborted."
    exit 0
fi

# ── Clean ────────────────────────────────────────────────────────────────────
echo "─────────────────────────────────────────────────────────────────────"
echo "[1/3] Cleaning build artifacts..."
echo "─────────────────────────────────────────────────────────────────────"
make clean
echo "✓ Clean complete"
echo ""

# ── Rebuild ──────────────────────────────────────────────────────────────────
echo "─────────────────────────────────────────────────────────────────────"
echo "[2/3] Rebuilding hardware-enabled backend..."
echo "─────────────────────────────────────────────────────────────────────"
echo "⏱️  This may take 5-10 minutes..."
make build_hw
echo "✓ Rebuild complete"
echo ""

# ── Tests ────────────────────────────────────────────────────────────────────
echo "─────────────────────────────────────────────────────────────────────"
echo "[3/3] Rebuilding tests..."
echo "─────────────────────────────────────────────────────────────────────"
make tests
echo "✓ Tests rebuilt"
echo ""

# ── Verify ───────────────────────────────────────────────────────────────────
echo "═══════════════════════════════════════════════════════════════════════"
echo "  ✅ Clean Rebuild Complete!"
echo "═══════════════════════════════════════════════════════════════════════"
echo ""
echo "Run smoke test?"
read -p "Press Enter to run simulation test, or Ctrl+C to skip: "
make smoke-sim
echo ""
echo "✅ All done!"
