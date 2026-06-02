# Troubleshooting Guide

## Common Issues and Solutions

This document covers issues encountered during the initial setup and their verified solutions.

---

## Build Issues

### ❌ `ModuleNotFoundError: No module named 'yaml'`

**Symptom:**
```
/work/tt-budabackend/src/ckernels/gen/genlist_ckernel.py: line 5: import: command not found
ModuleNotFoundError: No module named 'yaml'
```

**Root Cause:** Build scripts use `#!/usr/bin/env python3` shebangs and need system-wide PyYAML, not just in virtualenv.

**Solution:** Install PyYAML system-wide in Dockerfile:
```dockerfile
RUN pip3 install pyyaml numpy
```

**Why it works:** Scripts executed via shebang bypass virtualenv activation, so they need packages in system Python.

---

### ❌ `fatal error: zmq.hpp: No such file or directory`

**Symptom:**
```
/work/tt-budabackend/dbd/server/lib/inc/dbdserver/communication.h:9:10: 
fatal error: zmq.hpp: No such file or directory
```

**Root Cause:** Missing ZeroMQ C++ bindings required by debuda server.

**Solution:** Add ZeroMQ packages to Dockerfile:
```dockerfile
RUN apt-get install -y libzmq3-dev libczmq-dev

# Install cppzmq (C++ header bindings)
RUN cd /tmp && \
    git clone --depth 1 https://github.com/zeromq/cppzmq.git && \
    cd cppzmq && mkdir build && cd build && \
    cmake .. -DCPPZMQ_BUILD_TESTS=OFF && \
    make -j4 install && \
    cd /tmp && rm -rf cppzmq
```

---

### ❌ `git-lfs filter-process: git-lfs: not found`

**Symptom:**
```
git-lfs filter-process: 1: git-lfs: not found
fatal: the remote end hung up unexpectedly
fatal: 'git status --porcelain=2' failed in submodule third_party/sfpi
```

**Root Cause:** Git LFS not installed in container; `sfpi` submodule has LFS-tracked files.

**Solution:** Add git-lfs to Dockerfile:
```dockerfile
RUN apt-get install -y git git-lfs
```

---

### ❌ `can't cd to tt-budabackend` during `make clone`

**Symptom:**
```
[+] Initializing submodules...
/bin/sh: 11: cd: can't cd to tt-budabackend
```

**Root Cause:** Makefile commands in shell blocks don't preserve working directory between statements.

**Solution:** Chain all commands with `&&`:
```makefile
clone:
	@if [ -d "$(REPO_DIR)/.git" ]; then \
	  echo "[i] Already exists"; \
	else \
	  git clone $(REPO_URL) $(REPO_DIR) && \
	  cd $(REPO_DIR) && git checkout $(REPO_COMMIT) && \
	  git submodule update --init --recursive && \
	  echo "[✓] Submodules initialized"; \
	fi
```

---

### ❌ `Makefile:253: umd/device/module.mk: No such file or directory`

**Symptom:**
```
Makefile:253: umd/device/module.mk: No such file or directory
make[1]: *** No rule to make target 'umd/device/module.mk'.  Stop.
```

**Root Cause:** Git submodules not initialized properly.

**Solution:** Ensure `git submodule update --init --recursive` runs successfully in clone target (see above).

---

## Container Issues

### ❌ `bash: /home//.venv/bin/activate: No such file or directory`

**Symptom:** Empty username in venv path during container startup.

**Root Cause:** Dockerfile tries to use `${USERNAME}` variable after `USER` switch, but variable expansion doesn't work in that context.

**Solution:** Hardcode the username in venv paths:
```dockerfile
USER vscode

# Use hardcoded path, not ${USERNAME}
RUN python3 -m venv /home/vscode/.venv && \
    /home/vscode/.venv/bin/pip install pytest pyyaml numpy scipy && \
    echo 'source /home/vscode/.venv/bin/activate' >> /home/vscode/.bashrc
```

---

### ❌ `permission denied while trying to connect to Docker daemon`

**Symptom:**
```
Got permission denied while trying to connect to the Docker daemon socket
```

**Root Cause:** User not in `docker` group or group membership not active.

**Solution:**
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Activate group membership without logout
newgrp docker

# Restart VS Code from the newgrp shell
code .
```

---

### ❌ Dev container JSON parse errors

**Symptom:**
```
Error: Expected property name or '}' in JSON at position X
```

**Root Cause:** Comments (`//`) not allowed in strict JSON parsing mode.

**Solution:** Remove all `//` comments from `.devcontainer/devcontainer.json`.

---

### ❌ Wrong device paths in container

**Symptom:**
```
ls: cannot access '/dev/tenstorrent0': No such file or directory
```

**Root Cause:** Tenstorrent devices are at `/dev/tenstorrent/0` and `/dev/tenstorrent/1`, not `/dev/tenstorrent0`.

**Solution:** Update devcontainer.json mounts:
```json
"mounts": [
  "source=/dev/tenstorrent,target=/dev/tenstorrent,type=bind"
]
```

---

## Test Issues

### ❌ `VERSIM is not supported in this build`

**Symptom:**
```
terminate called after throwing an instance of 'std::runtime_error'
  what():  tt_VersimDevice() -- VERSIM is not supported in this build
```

**Root Cause:** Simulation backend not compiled in hardware-focused build.

**Solution:** Use silicon tests instead:
```bash
make smoke-silicon  # Not smoke-sim
```

**Note:** This is expected behavior for hardware-only builds.

---

### ❌ `no huge page mount found`

**Symptom:**
```
---- ttSiliconDevice::find_hugepage_dir: no huge page mount found in /proc/mounts 
     for path: /dev/hugepages-1G with hugepage_size: 1073741824.
```

**Impact:** Warning only; tests still work. Hugepages improve performance but aren't required.

**Optional Fix (host system):**
```bash
# Enable 1GB hugepages on host
echo 2 | sudo tee /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages
sudo mkdir -p /dev/hugepages-1G
sudo mount -t hugetlbfs -o pagesize=1G none /dev/hugepages-1G
```

---

## Verification Steps

After fixing issues, verify with:

```bash
# In container
cd /work

# Check environment
./scripts/01_verify_environment.sh

# Test on hardware
make smoke-silicon

# Expected output:
# [✓] Silicon test passed!
# Average pcc = 0.9999...
# Test Passed
```

---

## Getting Help

1. Check SETUP_GUIDE.md for detailed setup instructions
2. Review this troubleshooting guide for common issues
3. Check git log for recent changes: `git log --oneline`
4. Check container logs: `docker logs <container-id>`
5. For Tenstorrent-specific issues, see: https://github.com/tenstorrent/tt-budabackend

---

## Known Limitations

- **Python 3.10 required**: PyBuda breaks on Python 3.12+
- **Legacy hardware only**: Grayskull e150 (EOL), not compatible with modern TT-Forge
- **No simulation**: VERSIM not built; use silicon tests only
- **Frozen versions**: All software pinned to specific commits; do not upgrade
- **Hugepages optional**: Warning is cosmetic; performance impact minimal for testing

---

*Last Updated: 2025-10-23*
*Environment: Ubuntu 22.04, Docker 28.2.2, Python 3.10, tt-budabackend @ e4e03c8c*
