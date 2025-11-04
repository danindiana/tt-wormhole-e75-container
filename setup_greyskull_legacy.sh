#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# setup_greyskull_legacy.sh
# ─────────────────────────────────────────────────────────────────────────────
# Purpose: Prepare a reproducible legacy dev env for Tenstorrent Greyskull e150
# OS: Ubuntu 22.04 (tested); run with:  sudo bash setup_greyskull_legacy.sh
# Notes:
#   • You must supply legacy artifacts (KMD 1.31, fw_pack-80.14.0.0.fwbundle,
#     BUDA v0.19.3, Metalium v0.55) from your archive. This script lays out
#     paths and performs checks, but will not download EOL packages.
#   • Ensure BIOS PCIe AER = OS First; SR-IOV/IOMMU enabled if applicable.
#   • Runs idempotently where possible.

set -euo pipefail

### ── CONFIGURABLE PATHS (EDIT THESE) ─────────────────────────────────────────
# Put your legacy bundles/tarballs here before running the script.
LEGACY_ROOT="$HOME/tt_legacy_greyskull"
KMD_TARBALL="$LEGACY_ROOT/tt-kmd-1.31.tar.gz"          # e.g., driver source dkms tarball
FW_BUNDLE="$LEGACY_ROOT/fw_pack-80.14.0.0.fwbundle"    # Greyskull firmware bundle
BUDA_WHL_DIR="$LEGACY_ROOT/pybuda-0.19.3-wheels"       # optional: offline wheels cache

# Python venv for host-side tools (tt-smi/tt-flash python wrappers if applicable)
HOST_VENV_DIR="$HOME/.tenstorrent-venv"

### ── ROOT CHECK ──────────────────────────────────────────────────────────────
if [[ $EUID -ne 0 ]]; then
  echo "[!] Please re-run with sudo/root: sudo bash $0" >&2
  exit 1
fi

### ── DETECT DISTRO ──────────────────────────────────────────────────────────
. /etc/os-release
if [[ "${ID}" != "ubuntu" || "${VERSION_ID}" != "22.04" ]]; then
  echo "[!] This script targets Ubuntu 22.04; detected ${PRETTY_NAME}. Continuing anyway…" >&2
fi

### ── PREP WORKSPACE ─────────────────────────────────────────────────────────
mkdir -p "$LEGACY_ROOT"

### ── DEPENDENCIES ───────────────────────────────────────────────────────────
echo "[+] Installing system dependencies..."
apt-get update
apt-get install -y --no-install-recommends \
  build-essential dkms linux-headers-"$(uname -r)" \
  git curl wget jq python3 python3-venv python3-pip \
  cmake ninja-build pkg-config libssl-dev \
  pciutils usbutils udev lsb-release \
  podman || apt-get install -y docker.io

### ── UDEV RULES FOR DEVICE ACCESS ───────────────────────────────────────────
# Create a group for Tenstorrent devices and set udev rule for /dev/tenstorrent*
TT_GRP="tenstorrent"
if ! getent group "$TT_GRP" >/dev/null; then
  groupadd -r "$TT_GRP"
fi
usermod -aG "$TT_GRP" "${SUDO_USER:-$USER}" || true

UDEV_RULE_FILE="/etc/udev/rules.d/99-tenstorrent.rules"
cat > "$UDEV_RULE_FILE" << 'EOF'
KERNEL=="tenstorrent*", MODE="0660", GROUP="tenstorrent"
EOF
udevadm control --reload-rules && udevadm trigger || true

echo "[+] Udev rule installed at $UDEV_RULE_FILE; user added to group '$TT_GRP' (log out/in to apply)."

### ── INSTALL TT-KMD VIA DKMS (LEGACY) ───────────────────────────────────────
if [[ -f "$KMD_TARBALL" ]]; then
  echo "[+] Installing TT-KMD from $KMD_TARBALL..."
  WORKDIR="$(mktemp -d)"
  tar -xzf "$KMD_TARBALL" -C "$WORKDIR"
  pushd "$WORKDIR"/* >/dev/null
  if [[ -f "dkms.conf" ]]; then
    # Clean any previous dkms instance
    MOD_NAME=$(sed -n 's/^PACKAGE_NAME=\s*\"\?\(.*\)\"\?$/\1/p' dkms.conf | head -n1)
    MOD_VER=$(sed -n 's/^PACKAGE_VERSION=\s*\"\?\(.*\)\"\?$/\1/p' dkms.conf | head -n1)
    if dkms status | grep -q "${MOD_NAME}/${MOD_VER}"; then
      dkms remove -m "$MOD_NAME" -v "$MOD_VER" --all || true
    fi
    dkms add .
    dkms build -m "$MOD_NAME" -v "$MOD_VER"
    dkms install -m "$MOD_NAME" -v "$MOD_VER" --force
    echo "[+] DKMS installed ${MOD_NAME}/${MOD_VER}"
  else
    echo "[!] dkms.conf not found in extracted KMD tree; please verify tarball." >&2
  fi
  popd >/dev/null
  rm -rf "$WORKDIR"
else
  echo "[!] KMD tarball not found at $KMD_TARBALL; skipping driver install."
  echo "    Download tt-kmd v1.31 and place at: $KMD_TARBALL"
fi

### ── PYTHON VENV FOR HOST-TOOLS ────────────────────────────────────────────
echo "[+] Creating Python venv for host tools at $HOST_VENV_DIR..."
su - "${SUDO_USER:-$USER}" -c "python3 -m venv '$HOST_VENV_DIR'"
su - "${SUDO_USER:-$USER}" -c "'$HOST_VENV_DIR/bin/pip' install --upgrade pip wheel setuptools"

# Optional: if you maintain tt-smi/tt-flash Python wheels, install them here
if [[ -d "$BUDA_WHL_DIR" ]]; then
  su - "${SUDO_USER:-$USER}" -c "'$HOST_VENV_DIR/bin/pip' install --no-index --find-links='$BUDA_WHL_DIR' 'pybuda==0.19.3' || true"
fi

echo "[i] Host venv created at $HOST_VENV_DIR"
echo "    Activate with: source $HOST_VENV_DIR/bin/activate"

### ── FLASH GREYSKULL FIRMWARE (LEGACY) ──────────────────────────────────────
if [[ -f "$FW_BUNDLE" ]]; then
  echo "[i] Attempting firmware flash using fw bundle: $FW_BUNDLE"
  # Replace the following with your legacy flasher path if not in PATH.
  if command -v tt-flash >/dev/null 2>&1; then
    tt-flash --bundle "$FW_BUNDLE" --yes || {
      echo "[!] tt-flash failed — verify driver/card visibility." >&2
    }
  else
    echo "[!] tt-flash not found in PATH. Activate your host venv and/or install tt-flash." >&2
    echo "    Try: source $HOST_VENV_DIR/bin/activate && pip install tt-flash"
  fi
else
  echo "[!] Firmware bundle not found at $FW_BUNDLE; skipping flash."
  echo "    Download fw_pack-80.14.0.0.fwbundle and place at: $FW_BUNDLE"
fi

### ── BASIC CARD VERIFICATION ────────────────────────────────────────────────
echo ""
echo "[+] Verifying Tenstorrent device detection..."
set +e
if command -v tt-smi >/dev/null 2>&1; then
  echo "[i] Running tt-smi..."
  tt-smi || echo "[!] tt-smi returned non-zero; check driver/firmware status."
elif [[ -c /dev/tenstorrent0 ]]; then
  echo "[+] Device node /dev/tenstorrent0 exists (driver loaded)."
  lspci -d 1e52: -v | head -n 20
else
  echo "[!] No /dev/tenstorrent* devices found. Verify:"
  echo "    1. PCIe card is seated and powered"
  echo "    2. BIOS: PCIe AER = 'OS First'"
  echo "    3. Driver (tt-kmd) is loaded: lsmod | grep tenstorrent"
  lspci -d 1e52: || echo "    No Tenstorrent PCIe devices detected by lspci."
fi
set -e

echo ""
echo "──────────────────────────────────────────────────────────────────────────"
echo "[✓] Baseline host prep complete!"
echo ""
echo "Next steps:"
echo "  1. Log out/in or run: newgrp tenstorrent"
echo "  2. Open this project in VS Code"
echo "  3. Click 'Reopen in Container' when prompted"
echo "  4. Inside container: make deps && make build_hw && make smoke-silicon"
echo ""
echo "Manual fallback commands:"
echo "  - Check devices:  ls -l /dev/tenstorrent*"
echo "  - Run tt-smi:     source $HOST_VENV_DIR/bin/activate && tt-smi"
echo "  - Verify lspci:   lspci -d 1e52:"
echo "──────────────────────────────────────────────────────────────────────────"
