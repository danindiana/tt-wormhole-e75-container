# ─────────────────────────────────────────────────────────────────────────────
# Makefile — Tenstorrent Grayskull (e75/e150) Legacy Dev Environment
# ─────────────────────────────────────────────────────────────────────────────
# Purpose:
#   Clone, build, and test legacy tt-budabackend for Grayskull (ARCH_NAME=grayskull)
# Requirements:
#   - Run inside devcontainer (recommended) or on host with legacy stack
#   - ARCH_NAME must be 'grayskull' for Grayskull cards (e75/e150)
# Usage:
#   make deps          — Install Python dependencies
#   make clone         — Clone tt-budabackend at pinned commit
#   make build_hw      — Build hardware-enabled backend
#   make tests         — Build graph tests
#   make smoke-sim     — Run simulation test
#   make smoke-silicon — Run silicon test (requires a Grayskull card + drivers)

# ── Configuration ────────────────────────────────────────────────────────────
ARCH_NAME ?= grayskull
REPO_URL  := https://github.com/tenstorrent/tt-budabackend.git
REPO_DIR  := tt-budabackend

# Pinned commit for reproducibility (last known-good for Grayskull legacy)
# This is an example SHA; update to match your validated version
# For v0.19.3 era, find the commit from around that release
REPO_COMMIT := e4e03c8c2bf07af4ca5b878808408b89fd27778d

PY        := python3
VENV      := $(HOME)/.venv
NPROC     := $(shell nproc 2>/dev/null || echo 4)

# Paths relative to $(REPO_DIR)
TEST_BIN   := $(REPO_DIR)/build/test/verif/graph_tests/test_graph
NETLIST    ?= $(REPO_DIR)/verif/graph_tests/netlists/netlist_softmax_single_tile.yaml

# ── Phony Targets ────────────────────────────────────────────────────────────
.PHONY: help deps clone update clean build build_hw tests verif \
        smoke-sim smoke-silicon tt-smi env lock-check

# ── Default Target ───────────────────────────────────────────────────────────
.DEFAULT_GOAL := help

help:
	@echo "═══════════════════════════════════════════════════════════════════════"
	@echo "  Tenstorrent Grayskull (e75/e150) Legacy Build System"
	@echo "═══════════════════════════════════════════════════════════════════════"
	@echo ""
	@echo "Targets:"
	@echo "  deps           — Install Python deps in venv (pytest, pyyaml, numpy)"
	@echo "  clone          — Clone tt-budabackend at pinned commit (see Makefile.lock)"
	@echo "  update         — Update repo (use with caution; may break legacy builds)"
	@echo "  lock-check     — Verify repo is at pinned commit"
	@echo ""
	@echo "  build          — Generic 'make -j' inside $(REPO_DIR)"
	@echo "  build_hw       — 'make -j build_hw' (hardware-enabled build) [DEFAULT]"
	@echo "  tests          — Build graph tests"
	@echo ""
	@echo "  smoke-sim      — Run test_graph on netlist (simulation mode)"
	@echo "  smoke-silicon  — Run test_graph with --silicon (requires a Grayskull card + drivers)"
	@echo ""
	@echo "  clean          — Remove $(REPO_DIR)/build"
	@echo "  tt-smi         — Run tt-smi (if available; driver/card visibility)"
	@echo ""
	@echo "Variables:"
	@echo "  ARCH_NAME      = $(ARCH_NAME)"
	@echo "  REPO_DIR       = $(REPO_DIR)"
	@echo "  REPO_COMMIT    = $(REPO_COMMIT)"
	@echo "  NETLIST        = $(NETLIST)"
	@echo ""
	@echo "Quick start:"
	@echo "  make deps && make build_hw && make smoke-sim"
	@echo "  make smoke-silicon  # when card + firmware ready"
	@echo "═══════════════════════════════════════════════════════════════════════"

env:
	@echo "Environment:"
	@echo "  ARCH_NAME      = $(ARCH_NAME)"
	@echo "  REPO_DIR       = $(REPO_DIR)"
	@echo "  REPO_COMMIT    = $(REPO_COMMIT)"
	@echo "  NETLIST        = $(NETLIST)"
	@echo "  VENV           = $(VENV)"
	@echo "  NPROC          = $(NPROC)"
	@echo "  TEST_BIN       = $(TEST_BIN)"

# ── Python Dependencies ──────────────────────────────────────────────────────
deps:
	@echo "[+] Installing Python dependencies in $(VENV)..."
	@bash -lc "source $(VENV)/bin/activate 2>/dev/null || true; \
	           pip install --upgrade pip wheel setuptools pytest pyyaml numpy scipy"

# ── Clone Repository at Pinned Commit ────────────────────────────────────────
clone:
	@if [ -d "$(REPO_DIR)/.git" ]; then \
	  echo "[i] $(REPO_DIR) already exists; run 'make update' to refresh or 'make lock-check' to verify commit."; \
	else \
	  echo "[+] Cloning $(REPO_URL)..."; \
	  git clone $(REPO_URL) $(REPO_DIR) && \
	  cd $(REPO_DIR) && git checkout $(REPO_COMMIT) && \
	  echo "[✓] Checked out commit $(REPO_COMMIT)" && \
	  echo "$(REPO_COMMIT)" > ../Makefile.lock && \
	  echo "[i] Commit hash saved to Makefile.lock" && \
	  echo "[+] Initializing submodules..." && \
	  git submodule update --init --recursive && \
	  echo "[✓] Submodules initialized"; \
	fi

# ── Update Repository (with warning) ─────────────────────────────────────────
update:
	@if [ ! -d "$(REPO_DIR)/.git" ]; then \
	  echo "[!] $(REPO_DIR) not found; run 'make clone' first." >&2; \
	  exit 1; \
	fi
	@echo "[!] WARNING: Updating may break legacy builds. Press Ctrl+C to abort, Enter to continue..."
	@read -r
	cd $(REPO_DIR) && git fetch && git checkout $(REPO_COMMIT)
	@echo "[✓] Updated and checked out $(REPO_COMMIT)"

# ── Verify Pinned Commit ─────────────────────────────────────────────────────
lock-check:
	@if [ ! -d "$(REPO_DIR)/.git" ]; then \
	  echo "[!] $(REPO_DIR) not found; run 'make clone' first." >&2; \
	  exit 1; \
	fi
	@CURRENT=$$(cd $(REPO_DIR) && git rev-parse HEAD); \
	if [ "$$CURRENT" != "$(REPO_COMMIT)" ]; then \
	  echo "[!] Commit mismatch:"; \
	  echo "    Expected: $(REPO_COMMIT)"; \
	  echo "    Current:  $$CURRENT"; \
	  echo "    Run 'make clone' or 'make update' to fix."; \
	  exit 1; \
	else \
	  echo "[✓] Repo is at pinned commit $(REPO_COMMIT)"; \
	fi

# ── Build Targets ────────────────────────────────────────────────────────────
build: clone lock-check
	@echo "[+] Building tt-budabackend (generic)..."
	cd $(REPO_DIR) && \
	  export PATH=$(VENV)/bin:$$PATH && \
	  export ARCH_NAME=$(ARCH_NAME) && \
	  $(MAKE) -j$(NPROC)

build_hw: clone lock-check
	@echo "[+] Building tt-budabackend (hardware-enabled)..."
	cd $(REPO_DIR) && \
	  export PATH=$(VENV)/bin:$$PATH && \
	  export ARCH_NAME=$(ARCH_NAME) && \
	  $(MAKE) -j$(NPROC) build_hw

tests: clone lock-check
	@echo "[+] Building graph tests..."
	cd $(REPO_DIR) && \
	  export PATH=$(VENV)/bin:$$PATH && \
	  export ARCH_NAME=$(ARCH_NAME) && \
	  $(MAKE) -j$(NPROC) verif/graph_tests

verif: tests
	@echo "[i] 'verif' is an alias for 'tests'"

# ── Smoke Tests ──────────────────────────────────────────────────────────────
smoke-sim: tests
	@if [ ! -f "$(TEST_BIN)" ]; then \
	  echo "[!] Test binary not found: $(TEST_BIN)" >&2; \
	  echo "    Run 'make tests' first." >&2; \
	  exit 1; \
	fi
	@if [ ! -f "$(NETLIST)" ]; then \
	  echo "[!] Netlist not found: $(NETLIST)" >&2; \
	  exit 1; \
	fi
	@echo "[+] Running simulation smoke test..."
	cd $(REPO_DIR) && \
	  export ARCH_NAME=$(ARCH_NAME) && \
	  ./build/test/verif/graph_tests/test_graph \
	    --netlist $(NETLIST:$(REPO_DIR)/%=%)
	@echo "[✓] Simulation test passed!"

smoke-silicon: tests
	@if [ ! -f "$(TEST_BIN)" ]; then \
	  echo "[!] Test binary not found: $(TEST_BIN)" >&2; \
	  echo "    Run 'make tests' first." >&2; \
	  exit 1; \
	fi
	@if [ ! -f "$(NETLIST)" ]; then \
	  echo "[!] Netlist not found: $(NETLIST)" >&2; \
	  exit 1; \
	fi
	@echo "[+] Verifying Tenstorrent devices..."
	@ls /dev/tenstorrent* >/dev/null 2>&1 || { \
	  echo "[!] No /dev/tenstorrent* devices found. Check driver/firmware." >&2; \
	  exit 1; \
	}
	@echo "[+] Running silicon smoke test..."
	cd $(REPO_DIR) && \
	  export ARCH_NAME=$(ARCH_NAME) && \
	  ./build/test/verif/graph_tests/test_graph \
	    --netlist $(NETLIST:$(REPO_DIR)/%=%) \
	    --silicon
	@echo "[✓] Silicon test passed!"

# ── Utility Targets ──────────────────────────────────────────────────────────
clean:
	@if [ -d "$(REPO_DIR)/build" ]; then \
	  echo "[+] Cleaning $(REPO_DIR)/build..."; \
	  rm -rf $(REPO_DIR)/build; \
	  echo "[✓] Clean complete."; \
	else \
	  echo "[i] Nothing to clean."; \
	fi

tt-smi:
	@if command -v tt-smi >/dev/null 2>&1; then \
	  tt-smi; \
	else \
	  echo "[!] tt-smi not found in PATH." >&2; \
	  echo "    Install legacy tools or activate host venv." >&2; \
	fi
