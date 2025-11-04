# PyBuda Build from Source - Visual Process Flow

## 🎨 Complete Build Process Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                                                                     │
│                     PYBUDA BUILD FROM SOURCE                        │
│                         Process Flow                                │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘

                              START
                                │
                                ▼
                  ┌─────────────────────────┐
                  │  Download Scripts       │
                  │  chmod +x *.sh         │
                  └─────────────────────────┘
                                │
                                ▼
┌───────────────────────────────────────────────────────────────────────┐
│                                                                       │
│                         CHOOSE YOUR PATH                              │
│                                                                       │
│    ┌───────────────────────┐              ┌─────────────────────┐   │
│    │  AUTOMATED PATH       │              │   MANUAL PATH       │   │
│    │  (Recommended)        │              │   (Advanced)        │   │
│    │                       │              │                     │   │
│    │  bash                 │              │  Run scripts        │   │
│    │  0_run_all_steps.sh   │              │  individually       │   │
│    └───────────────────────┘              └─────────────────────┘   │
│              │                                       │               │
│              │                                       │               │
└──────────────┼───────────────────────────────────────┼───────────────┘
               │                                       │
               │                  ┌────────────────────┘
               │                  │
               ▼                  ▼
    ┌────────────────────────────────────────┐
    │                                        │
    │        STEP 1: DIAGNOSTICS             │
    │                                        │
    │  bash 4_diagnose_build_environment.sh  │
    │                                        │
    │  Checks:                               │
    │  ✓ Container running                   │
    │  ✓ Python 3.10                         │
    │  ✓ GCC compiler                        │
    │  ✓ yaml-cpp 0.7                        │
    │  ✓ boost 1.74                          │
    │  ✓ Build tools                         │
    │  ✓ Disk space                          │
    └────────────────────────────────────────┘
               │
               │  All checks pass? ──Yes──▶
               │                          │
               │  ◀──No─────────────────┐ │
               │                        │ │
               ▼                        │ │
         Fix issues                     │ │
               │                        │ │
               └────────────────────────┘ │
                                          │
                                          ▼
    ┌────────────────────────────────────────┐
    │                                        │
    │       STEP 2: LOCATE SOURCE            │
    │                                        │
    │  bash 1_locate_pybuda_source.sh        │
    │                                        │
    │  Searches for:                         │
    │  • tt-buda directories                 │
    │  • pybuda subdirectory                 │
    │  • setup.py                            │
    │  • budabackend build                   │
    └────────────────────────────────────────┘
               │
               │  Source found? ──Yes──▶
               │                        │
               │  ◀──No──────────────┐  │
               │                     │  │
               ▼                     │  │
      Update SOURCE_PATH             │  │
      in build script                │  │
               │                     │  │
               └─────────────────────┘  │
                                        │
                                        ▼
    ┌────────────────────────────────────────┐
    │                                        │
    │    STEP 3: BUILD PYBUDA (MAIN)         │
    │                                        │
    │  bash 3_build_pybuda_from_source.sh    │
    │                                        │
    │  Process:                              │
    │  1. Verify source accessible           │
    │  2. Install dependencies               │
    │     • pip install pybind11             │
    │     • pip install setuptools wheel     │
    │  3. Check budabackend built            │
    │  4. Install Python dependencies        │
    │  5. Clean previous builds              │
    │  6. Set environment variables          │
    │     • ARCH_NAME=wormhole_b0           │
    │  7. Build wheel                        │
    │     • python setup.py bdist_wheel     │
    │     ⏱ Takes 5-15 minutes              │
    │  8. Install wheel                      │
    │  9. Run tests                          │
    │  10. Create backup                     │
    └────────────────────────────────────────┘
               │
               │  Build success? ──Yes──▶
               │                         │
               │  ◀──No──────────────┐   │
               │                     │   │
               ▼                     │   │
      Check error messages           │   │
      Review troubleshooting          │   │
      Fix issues                      │   │
               │                     │   │
               └─────────────────────┘   │
                                         │
                                         ▼
    ┌────────────────────────────────────────┐
    │                                        │
    │      STEP 4: VERIFICATION              │
    │                                        │
    │  Automatic tests:                      │
    │  ✓ import pybuda                       │
    │  ✓ Check version                       │
    │  ✓ Import BackendType                  │
    │  ✓ No yaml-cpp errors                  │
    │  ✓ Device detection                    │
    └────────────────────────────────────────┘
               │
               │  All tests pass?
               │
       ┌───────┴────────┐
       │                │
     Yes               No
       │                │
       ▼                ▼
    SUCCESS!      Review logs
       │          Fix issues
       │                │
       └────────┬───────┘
                │
                ▼
    ┌────────────────────────────────────────┐
    │                                        │
    │         BUILD COMPLETE! 🎉             │
    │                                        │
    │  Results:                              │
    │  ✅ PyBuda installed                   │
    │  ✅ Wheel backed up                    │
    │  ✅ No ABI errors                      │
    │  ✅ Compatible with yaml-cpp 0.7       │
    │  ✅ Compatible with boost 1.74         │
    │  ✅ Ready for Wormhole B0              │
    │                                        │
    │  Backup location:                      │
    │  ~/pybuda-wheels-backup/               │
    └────────────────────────────────────────┘
                │
                ▼
    ┌────────────────────────────────────────┐
    │         NEXT STEPS                     │
    │                                        │
    │  1. Test with your models              │
    │  2. Run inference tests                │
    │  3. Update Dockerfile                  │
    │  4. Document process                   │
    │  5. Share with community               │
    │  6. Tackle firmware issue              │
    └────────────────────────────────────────┘
                │
                ▼
              END
```

## 📊 Timeline Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    BUILD TIMELINE                           │
└─────────────────────────────────────────────────────────────┘

Start                                                    End
│                                                          │
├──────────┬──────────┬──────────────────────┬───────────┤
│          │          │                      │           │
│   Prep   │   Diag   │     Build Phase     │   Test    │
│  1-2min  │  1-2min  │      5-15min        │  1-2min   │
│          │          │                      │           │
└──────────┴──────────┴──────────────────────┴───────────┘
                                                           
Total: 10-20 minutes
```

## 🔄 Error Recovery Flow

```
                    Build Error Occurs
                            │
                            ▼
                    ┌───────────────┐
                    │ Read Error    │
                    │ Message       │
                    └───────────────┘
                            │
            ┌───────────────┼───────────────┐
            │               │               │
            ▼               ▼               ▼
    ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
    │Missing       │  │Source Not    │  │Compilation   │
    │Dependency    │  │Found         │  │Error         │
    └──────────────┘  └──────────────┘  └──────────────┘
            │               │               │
            ▼               ▼               ▼
    ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
    │Install       │  │Update        │  │Check         │
    │Missing       │  │SOURCE_PATH   │  │Compiler      │
    │Package       │  │              │  │Flags         │
    └──────────────┘  └──────────────┘  └──────────────┘
            │               │               │
            └───────────────┼───────────────┘
                            │
                            ▼
                    ┌───────────────┐
                    │ Rebuild       │
                    └───────────────┘
                            │
                            ▼
                       Success!
```

## 🏗️ Component Relationship

```
┌─────────────────────────────────────────────────────────────┐
│                    BUILD COMPONENTS                         │
└─────────────────────────────────────────────────────────────┘

                    Host System
                    (baruch)
                        │
                        │ Source Code
                        │
            ┌───────────┴───────────┐
            │                       │
            ▼                       ▼
    /home/baruch/programs     Container
    /april16tt/               (tt-e75-dev)
         │                         │
         │                         │
         ├─ tt-buda/              Mount/Copy
         │  ├─ budabackend/  ────────▶
         │  │  └─ build/lib/        │
         │  │     └─ libdevice.so   │
         │  │                       │
         │  └─ pybuda/         ────▶│
         │     ├─ setup.py          │
         │     ├─ csrc/  ────────────────┐
         │     └─ pybuda/                │
         │                               │
         │                               ▼
         │                    ┌─────────────────┐
         │                    │  Build Process  │
         │                    │                 │
         │                    │  Compilation    │
         │                    │  Linking        │
         │                    │  Packaging      │
         │                    └─────────────────┘
         │                               │
         │                               ▼
         │                    ┌─────────────────┐
         │                    │  PyBuda Wheel   │
         │                    │  (.whl file)    │
         │                    └─────────────────┘
         │                               │
         │                               ▼
         │                    ┌─────────────────┐
         │                    │  Installation   │
         │                    │  in venv        │
         │                    └─────────────────┘
         │                               │
         │     Backup    ◀───────────────┘
         │       │
         ▼       ▼
    ~/pybuda-wheels-backup/
```

## 🎯 Dependency Chain

```
┌─────────────────────────────────────────────────────────────┐
│                  DEPENDENCY HIERARCHY                       │
└─────────────────────────────────────────────────────────────┘

                      PyBuda Wheel
                           │
         ┌─────────────────┼─────────────────┐
         │                 │                 │
         ▼                 ▼                 ▼
    Python Deps      C++ Libraries      Build Tools
         │                 │                 │
    ┌────┼────┐       ┌────┼────┐       ┌───┼───┐
    │    │    │       │    │    │       │   │   │
    ▼    ▼    ▼       ▼    ▼    ▼       ▼   ▼   ▼
  torch  tf numpy  yaml- boost  lib   gcc py  cmake
                   cpp-   1.74  device    bind
                   0.7         .so       11


Legend:
✅ = Already installed in container
⚠️ = May need installation
❌ = Not needed

torch       ✅ Installed (2.1.0)
tf          ✅ Installed (2.13.0)
numpy       ✅ Installed (1.23.1)
yaml-cpp    ✅ Installed (0.7) ← Fixed by building from source!
boost       ✅ Installed (1.74)
libdevice   ✅ Already built
gcc         ✅ Available
pybind11    ⚠️ Install with pip
cmake       ✅ Available
```

## 📈 Success Path vs Failure Path

```
┌─────────────────────────────────────────────────────────────┐
│                  PATH COMPARISON                            │
└─────────────────────────────────────────────────────────────┘

BEFORE (Pre-built Wheel)          AFTER (Build from Source)
──────────────────────            ─────────────────────────

    Install wheel                     Clone source
         │                                  │
         ▼                                  ▼
    Import PyBuda                     Build from source
         │                                  │
         ▼                                  ▼
    ❌ ERROR!                         Install wheel
    yaml-cpp 0.6                           │
    not found                              ▼
         │                            Import PyBuda
         ▼                                  │
    Development                             ▼
    BLOCKED ❌                          ✅ SUCCESS!
                                      Development
                                      CONTINUES ✅
```

## 🔧 Script Interaction Map

```
┌─────────────────────────────────────────────────────────────┐
│                  SCRIPT RELATIONSHIPS                       │
└─────────────────────────────────────────────────────────────┘

        0_run_all_steps.sh (Master)
                │
                │ Calls in sequence:
                │
        ┌───────┼────────┬────────┬───────┐
        │       │        │        │       │
        ▼       ▼        ▼        ▼       ▼
        4       1        2        3    (again 4)
      Diag   Locate   Analyze   Build   Verify
        │       │        │        │       │
        │       │        │        │       │
        ▼       ▼        ▼        ▼       ▼
      Pass    Found    (Skip)   Success  Pass
        │       │        │        │       │
        └───────┴────────┴────────┴───────┘
                        │
                        ▼
                  ✅ Complete!


Or run independently:

    4_diagnose     → Check status anytime
         │
    1_locate       → Find source first
         │
    3_build        → Main build process
         │
    4_diagnose     → Verify after build
```

---

## 📝 Legend

```
┌─────────┬──────────────────────────────────┐
│ Symbol  │ Meaning                          │
├─────────┼──────────────────────────────────┤
│   │     │ Sequential flow                  │
│   ▼     │ Direction of process             │
│  ┌─┐    │ Process or action                │
│  Yes/No │ Decision point                   │
│   ✅    │ Success / Already complete       │
│   ❌    │ Failure / Blocked                │
│   ⚠️    │ Warning / May need attention     │
│   ◀─    │ Return / Loop back               │
│   ⏱    │ Time indicator                   │
└─────────┴──────────────────────────────────┘
```

---

## 💡 Quick Visual Reference

### Most Common Path
```
Download → chmod +x → bash 0_run_all_steps.sh → Done!
   1min      1sec           15-20min           Success
```

### Troubleshooting Path
```
Error → bash 4_diagnose → Fix issue → Rebuild → Success
        Check logs         Address     Retry
```

### Manual Control Path
```
bash 4 → bash 1 → bash 3 → Test → Done!
 Diag     Locate   Build    Verify
```

---

**Use these diagrams to**:
- Understand the complete process
- Visualize dependencies
- Plan your approach
- Troubleshoot issues
- Explain to others

**Visual learning for the win! 🎨✨**
