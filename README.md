# Tenstorrent Wormhole e75 Development Environment

✅ **Status: VERIFIED WORKING** (2025-10-23)

A Docker-based development environment for Tenstorrent Wormhole e75 accelerators, with VS Code Dev Container integration.

## 📊 Architecture Diagrams

### System Architecture

```mermaid
graph TB
    subgraph Host["Host System (Ubuntu 22.04)"]
        VSCode["VS Code<br/>Dev Containers Extension"]
        Docker["Docker Engine"]
        Hardware["Tenstorrent Hardware<br/>/dev/tenstorrent/0<br/>/dev/tenstorrent/1"]
    end

    subgraph Container["Docker Container (Ubuntu 22.04)"]
        Python["Python 3.10.12<br/>PyBuda v0.19.3"]
        BuildTools["Build Tools<br/>GCC 11.4, CMake, Ninja"]
        Workspace["/work/"]
        Backend["tt-budabackend<br/>Pinned: e4e03c8c"]
    end

    VSCode -->|Reopen in Container| Container
    Docker -->|Device Passthrough| Hardware
    Container -->|Access Devices| Hardware
    BuildTools -->|Compiles| Backend
    Python -->|Uses| Backend
    Workspace -->|Contains| Backend

    style Container fill:#e1f5ff
    style Host fill:#fff4e6
    style Hardware fill:#ffe6e6
```

## ⚡ Quick Start

```bash
# Open in VS Code
code .

# Reopen in Container: Ctrl+Shift+P → "Dev Containers: Reopen in Container"

# Inside container:
make clone && make build_hw && make smoke-silicon
```

See **[QUICKSTART.md](QUICKSTART.md)** for detailed instructions.

## 🎯 What This Is

This repository provides a **complete, reproducible development environment** for:

- **Hardware**: 2x Tenstorrent Wormhole e75 PCIe cards
- **Software**: Legacy PyBuda v0.19.3 stack (frozen/pinned versions)
- **Purpose**: Develop and test neural network models on Greyskull hardware
- **Environment**: Containerized Ubuntu 22.04 with Python 3.10

## ✅ Verified Working

**Test Results** (2025-10-23):
```
[✓] Container builds successfully (5 min)
[✓] tt-budabackend compiles (10 min)
[✓] Silicon test passed (1.2s)
    - Detected: 2 PCI devices
    - Test: softmax single tile
    - Accuracy: PCC 0.9999, allclose 100%
```

**Hardware Tested**:
- 2x Tenstorrent Wormhole e75 (PCIe Vendor ID: 1e52)
- Devices: `/dev/tenstorrent/0` and `/dev/tenstorrent/1`

## 📦 What's Included

```
├── Dockerfile                  # Container with Python 3.10, build tools, ZeroMQ
├── .devcontainer/              # VS Code container config with device passthrough
├── Makefile                    # Build automation (clone, build_hw, tests)
├── Makefile.lock               # Pinned commit: e4e03c8c
├── scripts/
│   ├── 01_verify_environment.sh
│   ├── 02_first_build.sh
│   ├── 03_run_tests.sh
│   └── 04_clean_rebuild.sh
├── setup_greyskull_legacy.sh   # Host setup (requires legacy artifacts)
├── QUICKSTART.md               # 30-second setup guide
├── SETUP_GUIDE.md              # Detailed installation
└── TROUBLESHOOTING.md          # Common issues and solutions
```

## 🔧 Prerequisites

- **OS**: Ubuntu 22.04 LTS
- **Hardware**: Tenstorrent Wormhole e75 PCIe card(s)
- **Docker**: 20.10+ (user in docker group)
- **VS Code**: With Dev Containers extension (v0.427+)
- **Disk Space**: ~5GB for container, ~2GB for build artifacts

## 🌊 Data Flow Architecture

```mermaid
graph LR
    subgraph Input["Input Layer"]
        Netlists["Netlists<br/>.yaml files"]
        Models["Neural Network<br/>Models"]
    end

    subgraph Compilation["Compilation Layer"]
        PyBuda["PyBuda<br/>v0.19.3"]
        Backend["tt-budabackend<br/>Compiler/Runtime"]
        UMD["Unified Model Driver<br/>(UMD)"]
    end

    subgraph Hardware["Hardware Layer"]
        Device0["/dev/tenstorrent/0<br/>Wormhole e75"]
        Device1["/dev/tenstorrent/1<br/>Wormhole e75"]
    end

    subgraph Output["Output Layer"]
        Results["Test Results<br/>PCC Scores"]
        Logs["Build Logs<br/>Test Output"]
    end

    Netlists --> Backend
    Models --> PyBuda
    PyBuda --> Backend
    Backend --> UMD
    UMD --> Device0
    UMD --> Device1
    Device0 --> Results
    Device1 --> Results
    Backend --> Logs

    style Input fill:#E8F5E9
    style Compilation fill:#BBDEFB
    style Hardware fill:#FFCCBC
    style Output fill:#FFF9C4
```

## 🔄 Build Workflow

```mermaid
graph LR
    A[make clone] --> B[make build_hw]
    B --> C[make smoke-silicon]

    A -->|Alternative| D[make tests]
    D --> E[make smoke-sim]

    B -.->|If build fails| F[make clean]
    F -.-> B

    G[make deps] -.->|Install Python deps| A

    H[make lock-check] -.->|Verify commit| B

    style A fill:#90EE90
    style B fill:#87CEEB
    style C fill:#FFD700
    style E fill:#FFD700
    style F fill:#FFB6C1
```

### Build Target Dependencies

```mermaid
graph TD
    clone[make clone] --> lockcheck[make lock-check]
    lockcheck --> build[make build_hw]
    build --> tests[make tests]
    tests --> smoke-sim[make smoke-sim]
    tests --> smoke-silicon[make smoke-silicon]

    clean[make clean] -.->|Removes build/| build
    deps[make deps] -.->|Installs Python deps| clone
    update[make update] -.->|Updates repo| lockcheck

    style clone fill:#E8F5E9
    style build fill:#BBDEFB
    style tests fill:#FFF9C4
    style smoke-sim fill:#FFE0B2
    style smoke-silicon fill:#FFCCBC
```

## 🔧 Development Workflow

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant VSCode as VS Code
    participant Container as Dev Container
    participant Makefile as Makefile
    participant Backend as tt-budabackend
    participant Hardware as e75 Hardware

    Dev->>VSCode: Open repository
    VSCode->>Container: Reopen in Container
    Container->>Container: Mount /dev/tenstorrent

    Dev->>Makefile: make clone
    Makefile->>Backend: Clone at pinned commit
    Backend-->>Makefile: Repository ready

    Dev->>Makefile: make build_hw
    Makefile->>Backend: Compile with ARCH_NAME=wormhole_b0
    Backend-->>Makefile: Build complete

    Dev->>Makefile: make smoke-silicon
    Makefile->>Backend: Run test_graph --silicon
    Backend->>Hardware: Execute test on device
    Hardware-->>Backend: Test results
    Backend-->>Dev: ✓ Test passed

    Dev->>Dev: Modify code/netlists
    Dev->>Makefile: make clean && make build_hw
    Makefile->>Backend: Rebuild
    Backend-->>Dev: Ready for testing
```

## 📖 Documentation Structure

```mermaid
graph TD
    README[README.md<br/>Main Entry Point]

    README --> QuickStart[QUICKSTART.md<br/>30-second setup]
    README --> Setup[SETUP_GUIDE.md<br/>Detailed installation]
    README --> Troubleshoot[TROUBLESHOOTING.md<br/>Common issues]

    README --> GitPush[GITHUB_PUSH_GUIDE.md<br/>Git operations]
    README --> Summary[SUMMARY.txt<br/>Repository overview]

    README --> PyBuda[pybuda-build-helper/<br/>PyBuda build scripts]
    PyBuda --> BuildGuide[BUILD_FROM_SOURCE_GUIDE.md]
    PyBuda --> BuildScripts[Build Scripts 1-4]

    README --> Scripts[scripts/<br/>Helper scripts]
    Scripts --> Verify[01_verify_environment.sh]
    Scripts --> FirstBuild[02_first_build.sh]
    Scripts --> Tests[03_run_tests.sh]
    Scripts --> Clean[04_clean_rebuild.sh]

    style README fill:#4CAF50,color:#fff
    style QuickStart fill:#2196F3,color:#fff
    style Setup fill:#2196F3,color:#fff
    style Troubleshoot fill:#FF9800,color:#fff
    style PyBuda fill:#9C27B0,color:#fff
    style Scripts fill:#00BCD4,color:#fff
```

## 📖 Documentation

| Document | Purpose |
|----------|---------|
| **[QUICKSTART.md](QUICKSTART.md)** | Get running in 30 seconds |
| **[SETUP_GUIDE.md](SETUP_GUIDE.md)** | Comprehensive setup instructions |
| **[ARCHITECTURE.md](ARCHITECTURE.md)** | 🆕 Detailed system architecture and design |
| **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** | Solutions to common issues |
| **[GITHUB_PUSH_GUIDE.md](GITHUB_PUSH_GUIDE.md)** | Git operations and push guide |
| **[IMPROVEMENTS.md](IMPROVEMENTS.md)** | 🆕 Suggested repository improvements |
| **[pybuda-build-helper/](pybuda-build-helper/)** | PyBuda build-from-source tools |

## 🎓 Common Commands

```bash
# Build and test
make clone          # Clone tt-budabackend at pinned commit
make build_hw       # Build hardware backend
make smoke-silicon  # Quick hardware test

# Development
make clean          # Clean build artifacts
make update         # Update to pinned commit
make lock-check     # Verify at correct commit

# Helpers
./scripts/01_verify_environment.sh  # Check setup
./scripts/03_run_tests.sh           # Run full test suite
./scripts/04_clean_rebuild.sh       # Clean rebuild
```

## ⚠️ Important Notes

### Legacy Stack (FROZEN)

This environment uses **legacy, end-of-life software**:
- **Python 3.10 REQUIRED** (PyBuda breaks on 3.12+)
- **Wormhole e75** is EOL hardware
- **Do NOT upgrade** to mainline TT-Forge
- All versions frozen for reproducibility

### Pinned Versions

| Component | Version/Commit |
|-----------|----------------|
| tt-budabackend | `e4e03c8c2bf07af4ca5b878808408b89fd27778d` |
| PyBuda | v0.19.3 |
| TT-KMD | v1.31 |
| Firmware | fw_pack-80.14.0.0 |
| TT-Metalium | v0.55 |
| Python | 3.10.12 |

## 🐛 Troubleshooting

Common issues? Check **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** for:
- Build errors (PyYAML, ZeroMQ, git-lfs)
- Container issues (permissions, device access)
- Test failures (VERSIM, hugepages)

## 📊 Build Statistics

- **Container Build**: ~5 minutes (first time)
- **tt-budabackend Clone**: ~2 minutes (with submodules)
- **Hardware Build**: ~10 minutes (16 parallel jobs)
- **Smoke Test**: ~1-5 seconds
- **Total Setup Time**: ~20 minutes from scratch

## 🏗️ Architecture

```
Host (Ubuntu 22.04)
├── /dev/tenstorrent/0,1    ← Greyskull cards
│
└── Docker Container (Ubuntu 22.04)
    ├── Python 3.10.12
    ├── Build Tools (gcc 11.4, cmake 3.22, ninja 1.10)
    ├── Dependencies (ZeroMQ, Boost, PyYAML)
    └── /work/
        ├── tt-budabackend/        ← Compiler/runtime
        │   ├── build/lib/         ← Compiled libraries
        │   └── umd/               ← Unified Model Driver
        └── scripts/               ← Helper scripts
```

## 📝 Development Workflow

1. **Modify netlists**: Edit files in `tt-budabackend/verif/graph_tests/netlists/`
2. **Rebuild**: `make clean && make build_hw`
3. **Test**: `make smoke-silicon`
4. **Iterate**: Repeat as needed

## 🚀 Next Steps

After successful setup:
1. Explore example netlists in `tt-budabackend/verif/graph_tests/netlists/`
2. Run comprehensive tests: `./scripts/03_run_tests.sh`
3. Read tt-budabackend documentation
4. Customize Makefile targets for your workflow

## 🔀 Git Workflow

```mermaid
gitGraph
    commit id: "Initial setup"
    commit id: "Add Dockerfile & Makefile"
    commit id: "Add devcontainer config"
    branch feature/new-tests
    checkout feature/new-tests
    commit id: "Add new test netlists"
    commit id: "Update test scripts"
    checkout main
    merge feature/new-tests
    commit id: "Document changes"
    branch feature/pybuda-helper
    checkout feature/pybuda-helper
    commit id: "Add PyBuda build scripts"
    commit id: "Add build documentation"
    checkout main
    merge feature/pybuda-helper
    commit id: "Release v1.0"
```

### Git Operations Guide

```mermaid
flowchart TD
    Start([Start Development]) --> Clone[git clone repository]
    Clone --> Branch[git checkout -b feature/name]

    Branch --> Develop{Make Changes}
    Develop -->|Code Complete| Stage[git add .]
    Stage --> Commit[git commit -m message]

    Commit --> Test{Tests Pass?}
    Test -->|No| Fix[Fix Issues]
    Fix --> Develop
    Test -->|Yes| Push[git push origin feature/name]

    Push --> PR[Create Pull Request]
    PR --> Review{Review Approved?}
    Review -->|No| RequestChanges[Address Feedback]
    RequestChanges --> Develop
    Review -->|Yes| Merge[Merge to Main]

    Merge --> Tag[git tag -a v1.x.x]
    Tag --> End([Feature Complete])

    style Start fill:#90EE90
    style End fill:#FFD700
    style Test fill:#FFB6C1
    style Review fill:#FFB6C1
    style Merge fill:#87CEEB
```

## �� License

This repository configuration is provided as-is. Individual components (tt-budabackend, etc.) have their own licenses.

## 🔗 References

- [tt-budabackend](https://github.com/tenstorrent/tt-budabackend) - Deprecated backend compiler
- [tt-forge](https://github.com/tenstorrent/tt-forge) - Modern replacement (not compatible with Wormhole e75)
- [Tenstorrent](https://tenstorrent.com/) - Company website

---

**Created**: 2025-10-23 03:18:11  
**Last Verified**: 2025-10-23 09:37:00  
**Git Commits**: 5 (initial setup → working state)  
**Test Status**: ✅ PASSING (PCC 0.9999)
