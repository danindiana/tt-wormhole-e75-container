# Quick Start Guide

## Prerequisites

- Ubuntu 22.04 LTS (host)
- Tenstorrent Greyskull e150 card(s) installed
- Docker installed and user in docker group
- VS Code with Dev Containers extension

## 30-Second Setup

```bash
# 1. Clone this repository
cd ~/programs/tenstorrent-greyskull-dev_20251023_031811

# 2. Open in VS Code
code .

# 3. Open in container
# Press: Ctrl+Shift+P → "Dev Containers: Reopen in Container"
# Wait for container to build (~5 minutes first time)

# 4. Build and test (inside container)
make clone      # Clone tt-budabackend
make build_hw   # Build (~10 minutes)
make smoke-silicon  # Test on hardware (~5 seconds)
```

## Expected Output

```
[✓] Silicon test passed!
Average pcc = 0.9999087788213219
Test Passed
```

## Common Commands

### Inside Container

```bash
# Verify environment
./scripts/01_verify_environment.sh

# Build from scratch
make clean
make clone
make build_hw

# Run tests
make smoke-silicon          # Quick hardware test
./scripts/03_run_tests.sh   # Full test suite

# Clean rebuild
./scripts/04_clean_rebuild.sh
```

### Outside Container (Host)

```bash
# Rebuild container after Dockerfile changes
# In VS Code: Ctrl+Shift+P → "Dev Containers: Rebuild Container"

# Check device status
ls -l /dev/tenstorrent/
lspci | grep Tenstorrent

# View container logs
docker ps  # Get container ID
docker logs <container-id>
```

## File Structure

```
tenstorrent-greyskull-dev_20251023_031811/
├── Dockerfile              # Container definition (Python 3.10, build tools)
├── .devcontainer/
│   └── devcontainer.json   # VS Code container config
├── Makefile                # Build automation (clone, build_hw, tests)
├── Makefile.lock           # Pinned commit hash
├── scripts/
│   ├── 01_verify_environment.sh
│   ├── 02_first_build.sh
│   ├── 03_run_tests.sh
│   └── 04_clean_rebuild.sh
├── setup_greyskull_legacy.sh  # Host setup (requires legacy artifacts)
├── tt-budabackend/         # Cloned repository (created by make clone)
├── README.md               # Project overview
├── SETUP_GUIDE.md          # Detailed setup instructions
├── TROUBLESHOOTING.md      # Common issues and solutions
└── QUICKSTART.md           # This file
```

## Makefile Targets

```bash
make help           # Show all available targets
make deps           # Install Python dependencies
make clone          # Clone and checkout pinned commit
make build_hw       # Build hardware-enabled backend
make tests          # Build graph tests
make smoke-silicon  # Quick silicon test
make clean          # Clean build artifacts
make update         # Update to pinned commit (with warning)
make lock-check     # Verify at correct commit
```

## Troubleshooting

If you encounter issues, see `TROUBLESHOOTING.md` for solutions to:
- Build errors (PyYAML, ZeroMQ, git-lfs)
- Container issues (permissions, device access)
- Test failures (VERSIM, hugepages)

## Next Steps

1. **Explore netlists**: `tt-budabackend/verif/graph_tests/netlists/`
2. **Run more tests**: `cd tt-budabackend && make verif/graph_tests`
3. **Read documentation**: See `SETUP_GUIDE.md` for architecture details
4. **Customize workflows**: Edit `Makefile` and helper scripts

## Version Information

- **Environment**: Ubuntu 22.04, Docker 28.2.2, Python 3.10
- **Hardware**: Tenstorrent Greyskull e150 (ARCH_NAME=grayskull)
- **Software Stack**:
  - tt-budabackend: `e4e03c8c2bf07af4ca5b878808408b89fd27778d`
  - PyBuda: v0.19.3 (legacy)
  - TT-KMD: v1.31 (legacy)
  - Firmware: fw_pack-80.14.0.0 (legacy)

## Important Notes

⚠️ **This is a FROZEN legacy stack**
- Python 3.10 required (breaks on 3.12+)
- Do not upgrade to mainline TT-Forge
- Greyskull e150 is EOL hardware
- All versions pinned for reproducibility

✅ **Verified Working**
- Container builds successfully
- tt-budabackend compiles without errors
- Silicon tests pass on 2x Greyskull e150 cards
- Test accuracy: PCC 0.9999, allclose 100%

---

*For detailed information, see:*
- *README.md - Project overview and goals*
- *SETUP_GUIDE.md - Comprehensive setup instructions*
- *TROUBLESHOOTING.md - Solutions to common issues*

*Last Updated: 2025-10-23*
