# Tenstorrent Greyskull e150 Development Environment - Setup Guide

**Created:** October 23, 2025  
**Machine:** Ubuntu 22.04 with 2x Greyskull e150 cards  
**Status:** ✅ Fully Operational

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [How We Got Here](#how-we-got-here)
3. [What Was Created](#what-was-created)
4. [Quick Start](#quick-start)
5. [Troubleshooting](#troubleshooting)
6. [Next Steps](#next-steps)

---

## Overview

This is a **reproducible development environment** for Tenstorrent Greyskull e150 accelerator cards using:
- **Legacy frozen stack** (Greyskull is EOL)
- **Docker dev containers** for isolation
- **VS Code integration** for seamless workflow
- **Automated builds** via Makefile

### Hardware
- 2x Tenstorrent Greyskull e150 cards
- Devices: `/dev/tenstorrent/0` and `/dev/tenstorrent/1`

### Software Stack (Pinned/Legacy)
- Ubuntu 22.04 LTS
- Python 3.10 (legacy PyBuda requirement)
- TT-KMD v1.31
- Firmware: fw_pack-80.14.0.0
- PyBuda v0.19.3
- TT-Metalium v0.55

---

## How We Got Here

### Step 1: Project Structure Creation
```bash
# Created timestamped directory
mkdir -p ~/programs/tenstorrent-greyskull-dev_20251023_031811
cd ~/programs/tenstorrent-greyskull-dev_20251023_031811
```

### Step 2: Core Files Created

1. **`setup_greyskull_legacy.sh`** - Host system setup script
   - Installs TT-KMD driver via DKMS
   - Flashes firmware bundle
   - Creates udev rules for device access
   - Sets up host Python venv for tools

2. **`Dockerfile`** - Container definition
   - Base: Ubuntu 22.04
   - Python 3.10 verified
   - Non-root user (vscode)
   - Build tools: gcc, cmake, ninja, boost, etc.

3. **`.devcontainer/devcontainer.json`** - VS Code dev container config
   - Mounts `/dev/tenstorrent/` for hardware access
   - Privileged mode with IPC_LOCK capability
   - Auto-installs VS Code extensions (C++, Python, Docker)

4. **`Makefile`** - Build automation
   - Pinned commit hash for tt-budabackend
   - Targets: clone, build_hw, tests, smoke-sim, smoke-silicon
   - Environment: ARCH_NAME=grayskull

5. **`.vscode/tasks.json`** - VS Code tasks
   - One-click builds and tests
   - Device verification
   - tt-smi integration

6. **`.gitignore`** - Git exclusions
   - Build artifacts
   - Python cache
   - Large firmware bundles

### Step 3: Docker Installation
```bash
# Installed Docker
sudo apt update && sudo apt install -y docker.io

# Added user to docker group
sudo usermod -aG docker $USER

# Started and enabled Docker service
sudo systemctl start docker
sudo systemctl enable docker
```

### Step 4: Permission Fix
**Issue:** VS Code couldn't access Docker  
**Solution:** Restart VS Code from a shell with docker group active
```bash
# Close VS Code completely
# Open new terminal
newgrp docker
code ~/programs/tenstorrent-greyskull-dev_20251023_031811
```

### Step 5: Container Issues Resolved

**Issue 1:** Device path mismatch  
- **Problem:** Config tried `/dev/tenstorrent0` but devices at `/dev/tenstorrent/0`
- **Fix:** Updated `devcontainer.json` to mount `/dev/tenstorrent/`

**Issue 2:** Dockerfile syntax error  
- **Problem:** `RUN` and `ENV` commands combined incorrectly
- **Fix:** Separated into distinct statements

### Step 6: Success! 🎉
Container built successfully and opened in VS Code with full hardware access.

---

## What Was Created

```
tenstorrent-greyskull-dev_20251023_031811/
├── .devcontainer/
│   └── devcontainer.json          # VS Code container config
├── .vscode/
│   └── tasks.json                 # VS Code build/test tasks
├── Dockerfile                      # Container definition
├── Makefile                        # Build automation
├── Makefile.lock                   # Pinned commit SHA
├── setup_greyskull_legacy.sh      # Host setup script (executable)
├── .gitignore                      # Git exclusions
├── README.md                       # Original documentation
├── SETUP_GUIDE.md                 # This file
├── scripts/                        # Helper scripts (see below)
│   ├── 01_verify_environment.sh
│   ├── 02_first_build.sh
│   ├── 03_run_tests.sh
│   └── 04_clean_rebuild.sh
└── tt-budabackend/                # (created by 'make clone')
```

---

## Quick Start

### For First-Time Setup

1. **Obtain Legacy Artifacts** (contact Tenstorrent or check archives):
   ```bash
   mkdir -p ~/tt_legacy_greyskull
   # Place these files:
   # - tt-kmd-1.31.tar.gz
   # - fw_pack-80.14.0.0.fwbundle
   ```

2. **Run Host Setup** (one-time only):
   ```bash
   cd ~/programs/tenstorrent-greyskull-dev_20251023_031811
   sudo bash setup_greyskull_legacy.sh
   # Log out and back in (or run: newgrp tenstorrent)
   ```

3. **Open in VS Code**:
   ```bash
   # From a terminal with docker group active:
   newgrp docker
   code ~/programs/tenstorrent-greyskull-dev_20251023_031811
   ```

4. **Reopen in Container**:
   - Click "Reopen in Container" notification
   - Or: `Ctrl+Shift+P` → "Dev Containers: Reopen in Container"

5. **Build and Test** (inside container):
   ```bash
   make help          # See all targets
   make deps          # Install dependencies
   make clone         # Clone tt-budabackend
   make build_hw      # Build hardware-enabled
   make smoke-silicon # Test on hardware
   ```

### For Returning to Existing Setup

```bash
# 1. Open project
code ~/programs/tenstorrent-greyskull-dev_20251023_031811

# 2. Reopen in container (if not automatic)
# Click green icon in bottom-left → "Reopen in Container"

# 3. Inside container:
make help
```

---

## Troubleshooting

### Docker Permission Denied
**Symptom:** "permission denied while trying to connect to Docker daemon"  
**Solution:**
```bash
# Check group membership
groups | grep docker

# If not in group, add and restart:
sudo usermod -aG docker $USER
# Log out and back in, or:
newgrp docker
```

### Container Won't Start
**Check:**
```bash
# View Docker logs
docker ps -a
docker logs <container_id>

# Rebuild container
# In VS Code: Ctrl+Shift+P → "Dev Containers: Rebuild Container"
```

### Device Not Found
**Check devices exist:**
```bash
ls -la /dev/tenstorrent/
lspci -d 1e52:  # Tenstorrent vendor ID
```

**Check driver:**
```bash
lsmod | grep tenstorrent
sudo dmesg | grep tenstorrent
```

### Build Failures
**Clean rebuild:**
```bash
make clean
make build_hw
```

**Check pinned commit:**
```bash
make lock-check
```

---

## Next Steps

### Development Workflow

1. **Make code changes** in VS Code (changes are automatically synced to container)

2. **Build**:
   ```bash
   make build_hw
   ```

3. **Run tests**:
   ```bash
   make smoke-sim      # Simulation (no hardware)
   make smoke-silicon  # On hardware
   ```

4. **Use VS Code tasks**:
   - `Ctrl+Shift+P` → "Tasks: Run Task"
   - Select: "Build: Hardware (build_hw)" or "Silicon Smoke Test"

### Updating Pinned Commit

⚠️ **Use with caution** - may break legacy builds

```bash
# 1. Find new commit
cd tt-budabackend
git log --oneline | head -20

# 2. Update Makefile.lock
echo "NEW_COMMIT_SHA" > Makefile.lock

# 3. Update Makefile
vim Makefile  # Change REPO_COMMIT variable

# 4. Test
make update
make lock-check
make build_hw
```

### Sharing This Setup

This repository is ready to push to GitHub for reproducibility:

```bash
# Add remote
git remote add origin <your-repo-url>

# Commit and push
git add .
git commit -m "Initial Greyskull e150 dev environment"
git push -u origin main
```

**On another machine:**
```bash
git clone <your-repo-url>
cd tenstorrent-greyskull-dev_*
# Follow "Quick Start" above
```

---

## Helper Scripts

See `scripts/` directory for workflow automation:

- **`01_verify_environment.sh`** - Check devices, drivers, environment
- **`02_first_build.sh`** - Complete first-time build workflow
- **`03_run_tests.sh`** - Run full test suite
- **`04_clean_rebuild.sh`** - Clean and rebuild from scratch

---

## Important Notes

1. **Greyskull is EOL** - Do not upgrade to TT-Forge or mainline Metalium
2. **Python 3.10 only** - PyBuda v0.19.3 breaks on Python 3.12+
3. **Pinned versions** - All dependencies frozen for reproducibility
4. **tt-budabackend deprecated** - This is the last working version for Greyskull
5. **BIOS required** - PCIe AER must be "OS First" in BIOS

---

## Resources

- [Tenstorrent Greyskull Docs](https://docs.tenstorrent.com/aibs/grayskull/README.html)
- [tt-budabackend GitHub](https://github.com/tenstorrent/tt-budabackend)
- [tt-kmd GitHub](https://github.com/tenstorrent/tt-kmd)
- [PyBuda Docs](https://docs.tenstorrent.com/pybuda/latest/toc.html)

---

**Maintainer:** Created via GitHub Copilot for VS Code  
**Last Updated:** October 23, 2025  
**Status:** Production Ready ✅
