#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════════════════════
# 03_run_tests.sh
# ═════════════════════════════════════════════════════════════════════════════
# Purpose: Run the full test suite (simulation and silicon)
# Run: bash scripts/03_run_tests.sh

set -euo pipefail

echo "═══════════════════════════════════════════════════════════════════════"
echo "  Tenstorrent Grayskull e150 Test Suite"
echo "═══════════════════════════════════════════════════════════════════════"
echo ""

RESULTS_DIR="test_results_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$RESULTS_DIR"

# ── Check devices ────────────────────────────────────────────────────────────
echo "[Preflight] Checking Tenstorrent devices..."
if ! ls /dev/tenstorrent/* >/dev/null 2>&1; then
    echo "⚠️  No Tenstorrent devices found. Silicon tests will be skipped."
    SKIP_SILICON=1
else
    DEVICE_COUNT=$(ls -1 /dev/tenstorrent/ | wc -l)
    echo "✓ Found $DEVICE_COUNT Tenstorrent device(s)"
    SKIP_SILICON=0
fi
echo ""

# ── Simulation Test ──────────────────────────────────────────────────────────
echo "─────────────────────────────────────────────────────────────────────"
echo "[1/2] Running simulation test..."
echo "─────────────────────────────────────────────────────────────────────"

if make smoke-sim 2>&1 | tee "$RESULTS_DIR/simulation_test.log"; then
    echo "✅ Simulation test: PASSED"
    SIM_RESULT="PASS"
else
    echo "❌ Simulation test: FAILED"
    SIM_RESULT="FAIL"
fi
echo ""

# ── Silicon Test ─────────────────────────────────────────────────────────────
if [ $SKIP_SILICON -eq 0 ]; then
    echo "─────────────────────────────────────────────────────────────────────"
    echo "[2/2] Running silicon test..."
    echo "─────────────────────────────────────────────────────────────────────"
    
    if make smoke-silicon 2>&1 | tee "$RESULTS_DIR/silicon_test.log"; then
        echo "✅ Silicon test: PASSED"
        SILICON_RESULT="PASS"
    else
        echo "❌ Silicon test: FAILED"
        SILICON_RESULT="FAIL"
    fi
else
    echo "─────────────────────────────────────────────────────────────────────"
    echo "[2/2] Silicon test: SKIPPED (no devices)"
    echo "─────────────────────────────────────────────────────────────────────"
    SILICON_RESULT="SKIP"
fi
echo ""

# ── Generate Report ──────────────────────────────────────────────────────────
cat > "$RESULTS_DIR/summary.txt" << EOF
═══════════════════════════════════════════════════════════════════════
  Test Suite Summary
═══════════════════════════════════════════════════════════════════════

Date:        $(date)
Environment: $(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2 | tr -d '"')
Python:      $(python3 --version)
ARCH_NAME:   ${ARCH_NAME:-unset}

Results:
  Simulation Test:  $SIM_RESULT
  Silicon Test:     $SILICON_RESULT

Logs saved to: $RESULTS_DIR/
EOF

cat "$RESULTS_DIR/summary.txt"

# ── Exit Status ──────────────────────────────────────────────────────────────
if [[ "$SIM_RESULT" == "PASS" ]] && [[ "$SILICON_RESULT" == "PASS" || "$SILICON_RESULT" == "SKIP" ]]; then
    echo "✅ All tests passed!"
    exit 0
else
    echo "❌ Some tests failed. Check logs in: $RESULTS_DIR/"
    exit 1
fi
