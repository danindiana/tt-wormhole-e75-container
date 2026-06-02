# PyBuda Build from Source - Complete File Index

## 📦 Package Contents

This package contains **10 files** to help you build PyBuda from source:

### 🎯 Start Here
- **README.md** - Main overview and getting started guide

### 🏃 Quick Access
- **QUICK_REFERENCE.txt** - One-page command reference card

### 📚 Documentation  
- **BUILD_FROM_SOURCE_GUIDE.md** - Complete guide with troubleshooting

### 🔧 Executable Scripts (Run in Order)

| # | Script | Purpose | Run Order |
|---|--------|---------|-----------|
| 0 | **0_run_all_steps.sh** | Master script (runs all steps) | Run this OR run 1-4 manually |
| 1 | **1_locate_pybuda_source.sh** | Find source code | First |
| 2 | **2_analyze_build_requirements.sh** | Analyze source structure | Second (optional) |
| 3 | **3_build_pybuda_from_source.sh** | Build PyBuda (main script) | Third |
| 4 | **4_diagnose_build_environment.sh** | Check prerequisites | Run before build or anytime |

### 📋 This File
- **FILE_INDEX.md** - This comprehensive file listing

---

## 🚀 Two Ways to Build

### Option A: Automated (Recommended)

Run the master script which handles everything:

```bash
chmod +x 0_run_all_steps.sh
bash 0_run_all_steps.sh
```

The master script will:
1. Diagnose environment
2. Locate source
3. Build PyBuda
4. Test installation
5. Provide results

**Estimated time**: 10-20 minutes

### Option B: Manual (Step by Step)

Run each script individually for more control:

```bash
# Make scripts executable
chmod +x *.sh

# Step 1: Check environment
bash 4_diagnose_build_environment.sh

# Step 2: Find source
bash 1_locate_pybuda_source.sh

# Step 3 (optional): Analyze source
bash 2_analyze_build_requirements.sh

# Step 4: Build PyBuda
bash 3_build_pybuda_from_source.sh
```

**Estimated time**: 15-25 minutes

---

## 📖 Documentation Usage

### When to Read Each Document

**QUICK_REFERENCE.txt** - Use when:
- You need a quick command
- You've done this before
- You want a reminder
- You need to look up a common issue

**README.md** - Use when:
- First time using this package
- Need an overview
- Want to understand what's included
- Looking for file descriptions

**BUILD_FROM_SOURCE_GUIDE.md** - Use when:
- Need detailed instructions
- Encountering build errors
- Want to understand the process
- Need troubleshooting help
- Doing manual build

**FILE_INDEX.md** - Use when:
- Looking for a specific script
- Want to see all available resources
- Need to understand run order
- Comparing automated vs manual approaches

---

## 🔧 Script Details

### 0_run_all_steps.sh (Master Script)

**Purpose**: Automated build process with user prompts

**What it does**:
- Runs all steps in order
- Prompts for confirmation at each stage
- Provides colored output
- Shows progress
- Runs final verification tests

**When to use**: First time or when you want guided process

**Advantages**:
- Easiest to use
- Clear feedback
- Catches errors early
- Confirms success

### 1_locate_pybuda_source.sh

**Purpose**: Find PyBuda source code

**What it searches for**:
- tt-buda directories
- pybuda subdirectories  
- setup.py files
- CMakeLists.txt
- Build documentation

**Output**: Paths to source code locations

**Use when**: You're not sure where the source is located

### 2_analyze_build_requirements.sh

**Purpose**: Examine source structure and dependencies

**What it checks**:
- Directory structure
- setup.py presence
- requirements files
- C++ extensions
- Git repository status
- budabackend dependencies

**Output**: Source code analysis report

**Use when**: You want to understand the source before building

**Note**: This is optional - the build script will check essentials

### 3_build_pybuda_from_source.sh (Main Build Script)

**Purpose**: Complete automated build process

**What it does**:
1. Verifies source exists
2. Checks if source is accessible in container
3. Installs build dependencies
4. Verifies budabackend is built
5. Locates pybuda subdirectory
6. Installs Python dependencies
7. Cleans previous builds
8. Builds PyBuda wheel
9. Installs wheel
10. Tests installation
11. Copies wheel to backup location

**Time required**: 5-15 minutes

**Use when**: Ready to build PyBuda

**Advantages**:
- Fully automated
- Error checking at each step
- Creates backup
- Tests installation

### 4_diagnose_build_environment.sh

**Purpose**: Check if environment is ready to build

**What it checks**:
- Container status
- Python version
- C++ compiler
- CMake availability
- Required libraries (yaml-cpp, boost)
- Python build tools
- PyTorch/TensorFlow
- Current PyBuda status
- Disk space
- Source code availability

**Output**: Environment readiness report with ✓/✗/⚠ indicators

**Use when**: 
- Before building (recommended)
- Troubleshooting build failures
- Verifying environment setup
- Anytime you need to check status

**Advantages**:
- Quick health check
- Non-destructive
- Can run anytime
- Identifies missing dependencies

---

## 📊 Comparison Matrix

| Feature | Master Script (0) | Manual Steps (1-4) |
|---------|------------------|-------------------|
| **Ease of use** | ⭐⭐⭐⭐⭐ Easy | ⭐⭐⭐ Moderate |
| **Control** | ⭐⭐⭐ Moderate | ⭐⭐⭐⭐⭐ Full |
| **Time** | 10-20 min | 15-25 min |
| **Error handling** | Automatic | Manual |
| **User prompts** | Yes | No |
| **Best for** | First-time users | Experienced users |
| **Flexibility** | Fixed sequence | Can skip steps |

---

## 🎯 Success Indicators

After running the build (either method), you should see:

### During Build
✅ Source code found  
✅ Dependencies installed  
✅ budabackend verified  
✅ Wheel created in dist/  
✅ Installation successful  

### After Build
✅ `import pybuda` works  
✅ Version prints correctly  
✅ BackendType imports  
✅ No yaml-cpp errors  
✅ Wheel backed up  

---

## 🔍 Troubleshooting Quick Guide

### Build Failed
1. Check error messages carefully
2. Run diagnostic: `bash 4_diagnose_build_environment.sh`
3. Review BUILD_FROM_SOURCE_GUIDE.md troubleshooting section
4. Verify source path is correct

### Import Failed After Build
1. Check installation: `pip show pybuda`
2. Try force reinstall from backup
3. Check for old versions: `pip list | grep pybuda`
4. Verify library compatibility

### Source Not Found
1. Run locate script: `bash 1_locate_pybuda_source.sh`
2. Update SOURCE_PATH in build script
3. Verify source is accessible in container

---

## 📁 File Sizes (Approximate)

| File | Size | Type |
|------|------|------|
| README.md | ~12 KB | Documentation |
| BUILD_FROM_SOURCE_GUIDE.md | ~18 KB | Documentation |
| QUICK_REFERENCE.txt | ~8 KB | Reference |
| FILE_INDEX.md | ~6 KB | Reference |
| 0_run_all_steps.sh | ~8 KB | Script |
| 1_locate_pybuda_source.sh | ~2 KB | Script |
| 2_analyze_build_requirements.sh | ~3 KB | Script |
| 3_build_pybuda_from_source.sh | ~10 KB | Script |
| 4_diagnose_build_environment.sh | ~6 KB | Script |

**Total package size**: ~75 KB (lightweight!)

---

## 🔗 Related Resources

### In This Package
- All documentation is self-contained
- Scripts are standalone (except master script calls others)
- No external dependencies for scripts

### External Resources
- **Repository**: https://github.com/danindiana/tt-wormhole-e75-container
- **Community Help**: See COMMUNITY-HELP-REQUEST.md (if available)
- **Tenstorrent Discord**: For community support
- **GitHub Issues**: For bug reports

---

## 🎓 Learning Path

### Beginner
1. Read README.md
2. Read QUICK_REFERENCE.txt  
3. Run 0_run_all_steps.sh

### Intermediate
1. Read BUILD_FROM_SOURCE_GUIDE.md
2. Run scripts manually (1, 4, 3)
3. Review build output

### Advanced
1. Study 3_build_pybuda_from_source.sh
2. Customize for your needs
3. Integrate into your Dockerfile

---

## ✅ Checklist

Before you start:
- [ ] All scripts in same directory
- [ ] Scripts made executable (`chmod +x *.sh`)
- [ ] Container tt-e75-dev is running
- [ ] Source code available on host
- [ ] Read README.md or QUICK_REFERENCE.txt

During build:
- [ ] Diagnostic passed
- [ ] Source located
- [ ] Build completed without errors
- [ ] Tests passed

After build:
- [ ] PyBuda imports successfully
- [ ] No yaml-cpp errors
- [ ] Wheel backed up
- [ ] Ready to use

---

## 🎉 Next Steps After Success

1. **Test Your Models**
   - Run inference tests
   - Validate functionality
   - Benchmark performance

2. **Update Documentation**
   - Document your experience
   - Note any modifications needed
   - Share gotchas

3. **Automate Future Builds**
   - Update Dockerfile
   - Create CI/CD pipeline
   - Version control wheel

4. **Help the Community**
   - Share your success
   - Answer questions
   - Contribute improvements

---

## 📞 Support

If you need help:

1. **Check Documentation**
   - BUILD_FROM_SOURCE_GUIDE.md (most comprehensive)
   - QUICK_REFERENCE.txt (quick lookup)

2. **Run Diagnostics**
   - `bash 4_diagnose_build_environment.sh`
   - Review error messages

3. **Community Support**
   - Tenstorrent Discord
   - GitHub Discussions
   - GitHub Issues

4. **Official Support**
   - support@tenstorrent.com

---

## 📝 Version Info

**Package Version**: 1.0  
**Created**: November 3, 2025  
**Target**: Tenstorrent Grayskull e75  
**Architecture**: grayskull  
**Container**: tt-e75-dev (Ubuntu 22.04)  

---

## 🏆 Credits

This package was created to solve the PyBuda C++ ABI compatibility issue
encountered when setting up a Grayskull e75 development environment.

The solution: Build PyBuda from source to ensure compatibility with
container libraries (yaml-cpp 0.7, boost 1.74).

**Special thanks to**:
- Tenstorrent community
- tt-buda developers
- Open source contributors

---

**Happy Building! 🚀**

For questions or improvements, please open an issue in the repository.
