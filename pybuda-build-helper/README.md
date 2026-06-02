# Building PyBuda from Source - Complete Resource Package

## 📦 What's in This Package

This package contains everything you need to build PyBuda from source to resolve C++ ABI compatibility issues with the Grayskull e75 container.

### 📄 Documentation Files

| File | Purpose | When to Use |
|------|---------|-------------|
| **QUICK_REFERENCE.txt** | One-page command reference | Quick lookup, at-a-glance guide |
| **BUILD_FROM_SOURCE_GUIDE.md** | Complete build instructions | Detailed guide with troubleshooting |
| **README.md** | This file | Overview of all resources |

### 🔧 Executable Scripts

| Script | Purpose | Run Order |
|--------|---------|-----------|
| **1_locate_pybuda_source.sh** | Find PyBuda source on host | Run first |
| **2_analyze_build_requirements.sh** | Check source structure | Run second (optional) |
| **3_build_pybuda_from_source.sh** | Automated build process | Run third (main script) |
| **4_diagnose_build_environment.sh** | Check build prerequisites | Run anytime for diagnostics |

## 🚀 Quick Start

### Step 0: Make Scripts Executable

```bash
cd /path/to/this/directory
chmod +x *.sh
```

### Step 1: Diagnose Environment

Check if everything is ready:

```bash
bash 4_diagnose_build_environment.sh
```

Expected output: All critical checks should pass (✓)

### Step 2: Locate Source Code

Find where PyBuda source is located:

```bash
bash 1_locate_pybuda_source.sh
```

Expected output: Should find `/home/baruch/programs/april16tt/tt-buda`

### Step 3: Build PyBuda

Run the automated build:

```bash
bash 3_build_pybuda_from_source.sh
```

Expected time: 5-15 minutes

### Step 4: Test Installation

Verify PyBuda works:

```bash
ssh baruch@192.168.1.158 'docker exec tt-e75-dev python -c "import pybuda; print(pybuda.__version__)"'
```

Expected output: Version number prints without errors

## 🎯 What This Solves

### The Problem

Your tt-e75-dev container has a PyBuda installation issue:

```
ImportError: libyaml-cpp.so.0.6: cannot open shared object file
```

**Root Cause**: The pre-built PyBuda wheel was compiled against yaml-cpp 0.6, but your container has yaml-cpp 0.7. This is a C++ ABI incompatibility.

### The Solution

Build PyBuda from source **inside** your container. This ensures:
- ✅ Compiled against yaml-cpp 0.7 (your container's version)
- ✅ Compiled against boost 1.74 (your container's version)
- ✅ Compatible with all container libraries
- ✅ No ABI mismatches
- ✅ Works with Grayskull hardware

## 📋 Prerequisites

### Hardware
- ✅ Grayskull e75 card installed and accessible
- ✅ /dev/tenstorrent/1 device available

### Software (Already Installed)
- ✅ Ubuntu 22.04 container (tt-e75-dev)
- ✅ Python 3.10
- ✅ PyTorch 2.1.0
- ✅ TensorFlow 2.13.0
- ✅ Boost 1.74
- ✅ yaml-cpp 0.7
- ✅ GCC/G++ compiler

### Source Code
- ✅ tt-buda source at `/home/baruch/programs/april16tt/tt-buda`
- ✅ budabackend already compiled (libdevice.so)

## 🏗️ Build Process Overview

```
┌─────────────────────────────────────────────────────┐
│ 1. Locate Source                                    │
│    └─> Finds tt-buda on host system                │
├─────────────────────────────────────────────────────┤
│ 2. Verify Environment                               │
│    └─> Checks libraries, tools, dependencies       │
├─────────────────────────────────────────────────────┤
│ 3. Install Build Dependencies                       │
│    └─> pip install setuptools wheel pybind11       │
├─────────────────────────────────────────────────────┤
│ 4. Verify budabackend                               │
│    └─> Check libdevice.so exists                   │
├─────────────────────────────────────────────────────┤
│ 5. Clean Previous Builds                            │
│    └─> Remove old build/, dist/, *.egg-info        │
├─────────────────────────────────────────────────────┤
│ 6. Build PyBuda Wheel                               │
│    └─> python setup.py bdist_wheel                 │
│        (This takes 5-15 minutes)                    │
├─────────────────────────────────────────────────────┤
│ 7. Install Wheel                                    │
│    └─> pip install dist/*.whl                      │
├─────────────────────────────────────────────────────┤
│ 8. Test Installation                                │
│    └─> import pybuda, check version                │
├─────────────────────────────────────────────────────┤
│ 9. Backup Wheel                                     │
│    └─> Copy to ~/pybuda-wheels-backup/             │
└─────────────────────────────────────────────────────┘
```

## 🔍 Script Details

### 1_locate_pybuda_source.sh

**Purpose**: Find PyBuda source code on the host system

**What it does**:
- Searches for tt-buda directories
- Looks for pybuda subdirectories
- Finds setup.py and CMakeLists.txt
- Checks directory structure

**Expected output**: Path to tt-buda source

### 2_analyze_build_requirements.sh

**Purpose**: Analyze the source structure and dependencies

**What it does**:
- Verifies source directory exists
- Checks for setup.py
- Looks for requirements files
- Examines C++ extensions
- Checks git status

**Expected output**: Source structure analysis

### 3_build_pybuda_from_source.sh

**Purpose**: Automated build process (MAIN SCRIPT)

**What it does**:
- Verifies source location
- Installs dependencies
- Checks budabackend build
- Builds PyBuda wheel
- Installs wheel
- Tests installation
- Creates backup

**Expected output**: Working PyBuda installation

**Time required**: 5-15 minutes

### 4_diagnose_build_environment.sh

**Purpose**: Check if environment is ready to build

**What it does**:
- Checks container status
- Verifies Python version
- Checks C++ compiler
- Examines required libraries
- Tests Python packages
- Checks disk space

**Expected output**: Environment readiness report

**Run this**: Before attempting build

## 📖 Documentation Details

### QUICK_REFERENCE.txt

One-page quick reference with:
- 5-command quick start
- File reference guide
- Common issues & fixes
- Manual build instructions
- Success indicators

**Use when**: You need a quick command or reminder

### BUILD_FROM_SOURCE_GUIDE.md

Comprehensive guide with:
- Detailed prerequisites
- Step-by-step instructions
- Architecture explanation
- Troubleshooting section
- Alternative approaches
- Development tips

**Use when**: You need detailed information or encounter problems

## ⚠️ Important Notes

### Architecture

The build is configured for **Grayskull**:
```bash
export ARCH_NAME=grayskull
export BACKEND_ARCH_NAME=grayskull
```

### Source Mounting

The source code should be accessible in the container. The script checks:
1. `/host_home/programs/april16tt/tt-buda` (if host home is mounted)
2. `/workspace/tt-buda` (if copied)
3. `/workspace/tt-buda-source` (alternative location)

### Build Dependencies

Most dependencies are already installed, but you may need:
- pybind11 (for Python/C++ bindings)
- setuptools, wheel (for building)

The automated script installs these automatically.

### Disk Space

Building requires approximately 2-5GB of free space:
- Source code: ~500MB
- Build artifacts: 1-2GB
- Wheel file: ~100-200MB

## 🔧 Troubleshooting

### Build Fails

1. **Check diagnostics first**:
   ```bash
   bash 4_diagnose_build_environment.sh
   ```

2. **Read error messages carefully** - they usually point to the issue

3. **Check BUILD_FROM_SOURCE_GUIDE.md** - Has detailed troubleshooting

### Import Still Fails After Build

1. **Verify wheel was installed**:
   ```bash
   ssh baruch@192.168.1.158 'docker exec tt-e75-dev pip show pybuda'
   ```

2. **Check for old installations**:
   ```bash
   ssh baruch@192.168.1.158 'docker exec tt-e75-dev pip list | grep pybuda'
   ```

3. **Reinstall with force**:
   ```bash
   ssh baruch@192.168.1.158 'docker exec tt-e75-dev pip install ~/pybuda-wheels-backup/*.whl --force-reinstall --break-system-packages'
   ```

### Source Not Found

Update `SOURCE_PATH` in the build script to your actual location:

```bash
# Edit this line in 3_build_pybuda_from_source.sh
SOURCE_PATH="/home/baruch/programs/april16tt/tt-buda"
```

## ✅ Success Criteria

After a successful build, you should be able to:

1. **Import PyBuda**:
   ```python
   import pybuda
   print(pybuda.__version__)
   ```

2. **Import Backend Types**:
   ```python
   from pybuda import BackendType
   ```

3. **Detect Devices** (if hardware accessible):
   ```python
   import pybuda
   devices = pybuda.detect_available_devices()
   print(devices)
   ```

4. **No yaml-cpp errors** when importing

## 🎉 After Successful Build

### 1. Test Functionality

Run basic PyBuda tests to ensure everything works.

### 2. Backup the Wheel

The script automatically copies the wheel to:
```
/home/baruch/pybuda-wheels-backup/
```

Keep this backup for reinstallation if needed.

### 3. Update Your Dockerfile

Modify your Dockerfile to build PyBuda from source instead of using pre-built wheels.

### 4. Document Your Process

Add notes to your repository about:
- What worked
- Any changes needed
- Gotchas encountered

### 5. Share with Community

Post your success on:
- Tenstorrent Discord
- GitHub Discussions
- Your repository

Help others who might encounter the same issue!

## 📞 Getting Help

### If This Package Doesn't Work

1. **Check diagnostics**: Run `4_diagnose_build_environment.sh`
2. **Review guide**: Read `BUILD_FROM_SOURCE_GUIDE.md` thoroughly
3. **Check error messages**: They usually indicate the problem
4. **Search issues**: GitHub issues for tt-buda/tt-budabackend
5. **Ask community**: Discord, GitHub Discussions

### Resources

- **Documentation**: BUILD_FROM_SOURCE_GUIDE.md
- **Quick Help**: QUICK_REFERENCE.txt
- **Community Help**: COMMUNITY-HELP-REQUEST.md
- **Repository**: https://github.com/danindiana/tt-wormhole-e75-container

## 🔗 Related Issues

This build-from-source approach solves the **PyBuda installation issue**.

You may still need to address the **firmware build issue** separately:
- See COMMUNITY-HELP-REQUEST.md for guidance
- Post to Discord/GitHub for help with firmware

## 📝 Summary

This package provides:
- ✅ 4 automated scripts
- ✅ 3 documentation files  
- ✅ Step-by-step guidance
- ✅ Troubleshooting help
- ✅ Quick reference

**Start here**: Run `bash 4_diagnose_build_environment.sh` then `bash 3_build_pybuda_from_source.sh`

**Get help**: Check `BUILD_FROM_SOURCE_GUIDE.md` and `QUICK_REFERENCE.txt`

**Expected time**: 5-15 minutes to complete build

**Expected result**: Working PyBuda installation with no ABI issues

---

**Created**: November 3, 2025  
**For**: Tenstorrent Grayskull e75 Development  
**Repository**: https://github.com/danindiana/tt-wormhole-e75-container

**Good luck with your build! 🚀**
