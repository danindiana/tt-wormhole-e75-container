# Building PyBuda from Source - Complete Guide

## Why Build from Source?

Building PyBuda from source will:
- ✅ Compile against your exact library versions (yaml-cpp 0.7, boost 1.74)
- ✅ Ensure compatibility with Grayskull hardware
- ✅ Resolve C++ ABI incompatibility issues
- ✅ Give you control over build configuration
- ✅ Allow debugging if needed

## Prerequisites

### 1. Source Code Location
Run the discovery script to find your PyBuda source:
```bash
bash 1_locate_pybuda_source.sh
```

Expected location: `/home/baruch/programs/april16tt/tt-buda`

### 2. Build Dependencies

Your container should already have most dependencies:
- ✅ Python 3.10
- ✅ GCC/G++ compiler
- ✅ CMake
- ✅ Boost 1.74 (just installed)
- ✅ yaml-cpp 0.7 (installed)
- ✅ TensorFlow 2.13 (installed)
- ✅ PyTorch 2.1.0 (installed)

Additional dependencies may be needed:
- pybind11 (Python/C++ bindings)
- numpy development headers
- CUDA toolkit (for GPU support, optional)

## Build Process Overview

PyBuda typically consists of:
1. **budabackend** - C++ core library (already built: libdevice.so)
2. **pybuda** - Python package with C++ extensions

The relationship:
```
tt-buda/
├── third_party/budabackend/  ← C++ core (already built)
│   └── build/lib/libdevice.so
└── pybuda/                     ← Python package (needs building)
    ├── setup.py
    ├── csrc/                   ← C++ Python bindings
    └── pybuda/                 ← Python code
```

## Step-by-Step Build Instructions

### Step 1: Verify Source Code

Run on your local machine (worlock):
```bash
bash 1_locate_pybuda_source.sh
bash 2_analyze_build_requirements.sh
```

### Step 2: Copy Source to Container

The source needs to be accessible inside the container. Check if it's already mounted:

```bash
ssh baruch@192.168.1.158 'docker exec tt-e75-dev ls -la /workspace 2>/dev/null'
```

If not mounted, you have options:
- **Option A**: Mount the source directory (requires container restart)
- **Option B**: Copy source into container
- **Option C**: Git clone inside container

### Step 3: Install Build Dependencies

Inside the container:
```bash
docker exec -it tt-e75-dev bash

# Install Python build tools
pip install --upgrade pip setuptools wheel --break-system-packages
pip install pybind11 --break-system-packages

# Install additional dependencies (if needed)
apt-get update
apt-get install -y python3-dev cmake ninja-build
```

### Step 4: Build budabackend (C++ Core)

If not already built:
```bash
cd /workspace/tt-buda  # or wherever source is located
make -j8 build_hw ARCH_NAME=grayskull
```

Verify:
```bash
ls -la third_party/budabackend/build/lib/libdevice.so
```

### Step 5: Build PyBuda Python Package

```bash
cd /workspace/tt-buda/pybuda

# Clean previous builds
rm -rf build/ dist/ *.egg-info

# Build with architecture specified
export ARCH_NAME=grayskull
export BACKEND_ARCH_NAME=grayskull

# Option A: Build wheel
python setup.py bdist_wheel

# Option B: Build and install directly
pip install -e . --break-system-packages
```

### Step 6: Install and Test

If you built a wheel:
```bash
cd dist/
pip install pybuda-*.whl --break-system-packages --force-reinstall
```

Test:
```bash
python -c "import pybuda; print('PyBuda version:', pybuda.__version__)"
python -c "from pybuda import BackendType; print('Backend types:', dir(BackendType))"
```

## Troubleshooting Common Issues

### Issue 1: budabackend Not Found
**Error**: `cannot find budabackend library`

**Solution**:
```bash
# Ensure budabackend is built first
cd /workspace/tt-buda
make build_hw ARCH_NAME=grayskull

# Set library path
export LD_LIBRARY_PATH=/workspace/tt-buda/build/lib:$LD_LIBRARY_PATH
```

### Issue 2: Missing Python Dependencies
**Error**: `ModuleNotFoundError: No module named 'xyz'`

**Solution**:
```bash
# Check pybuda requirements
cat pybuda/requirements.txt

# Install missing packages
pip install -r pybuda/requirements.txt --break-system-packages
```

### Issue 3: C++ Compiler Errors
**Error**: `error: 'something' has not been declared`

**Solution**:
```bash
# Ensure correct compiler flags
export CXXFLAGS="-std=c++17 -fPIC"
export CFLAGS="-fPIC"

# Rebuild
python setup.py clean --all
python setup.py bdist_wheel
```

### Issue 4: yaml-cpp Version Mismatch
**Error**: `undefined symbol: _ZN4YAML...`

**Solution**: Building from source should fix this! The build will link against
the yaml-cpp 0.7 in your container.

### Issue 5: Architecture Mismatch
**Error**: `Unknown architecture` or `arch not supported`

**Solution**:
```bash
# Explicitly set architecture
export ARCH_NAME=grayskull
export BACKEND_ARCH_NAME=grayskull

# Verify it's picked up
echo $ARCH_NAME
```

## Alternative: Development Install

For development/debugging, install in editable mode:

```bash
cd /workspace/tt-buda/pybuda

# Install in development mode
pip install -e . --break-system-packages

# Changes to Python code take effect immediately
# C++ changes require rebuild: python setup.py build_ext --inplace
```

## Automated Build Script

See `3_build_pybuda_from_source.sh` for an automated build script.

## Expected Build Time

- **budabackend** (C++ core): 10-30 minutes (already done)
- **pybuda** (Python + extensions): 5-15 minutes
- **Total**: ~15-45 minutes

## Success Criteria

✅ Build completes without errors
✅ Wheel file created in `dist/` directory
✅ `import pybuda` works in Python
✅ Can access device: `pybuda.detect_available_devices()`
✅ No yaml-cpp errors

## Next Steps After Successful Build

1. Test basic PyBuda functionality
2. Run model inference tests
3. Create wheel backup for reinstallation
4. Document the build process in your repository
5. Update your container Dockerfile to build from source

## Sharing Back with Community

Once you have a working build:
1. Document the exact steps in your GitHub repo
2. Note any gotchas or deviations
3. Share on Discord/GitHub discussions
4. Help others who encounter similar issues

---

**Note**: The exact build process may vary depending on the PyBuda version
and repository structure. Adjust paths and commands as needed based on your
actual source code layout.
