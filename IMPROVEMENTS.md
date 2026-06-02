# Repository Structure Improvements

This document outlines suggested improvements to the repository structure and organization.

## Current Structure Analysis

### Strengths ✅

1. **Clear documentation hierarchy** with README, QUICKSTART, SETUP_GUIDE, and TROUBLESHOOTING
2. **Organized scripts** in dedicated `scripts/` directory
3. **Separate PyBuda helper** in `pybuda-build-helper/` subdirectory
4. **Dev container integration** for VS Code
5. **Pinned versions** for reproducibility

### Areas for Improvement 🔧

1. **Documentation consolidation** - Multiple similar files (GITHUB_PUSH.md vs. GITHUB_PUSH_GUIDE.md)
2. **Missing architecture documentation** - No high-level system overview (NOW ADDED!)
3. **No contribution guidelines** - Missing CONTRIBUTING.md
4. **Flat documentation structure** - All docs in root directory
5. **No CI/CD configuration** - Missing automated testing

## Proposed Improvements

### 1. Documentation Reorganization

#### Create `docs/` Directory

```
docs/
├── getting-started/
│   ├── QUICKSTART.md
│   └── SETUP_GUIDE.md
├── development/
│   ├── ARCHITECTURE.md
│   ├── CONTRIBUTING.md
│   └── DEVELOPMENT_WORKFLOW.md
├── operations/
│   ├── TROUBLESHOOTING.md
│   └── MAINTENANCE.md
└── reference/
    ├── MAKEFILE_REFERENCE.md
    └── API_REFERENCE.md
```

**Benefits**:
- Clearer organization by purpose
- Easier to navigate for new users
- Scalable as documentation grows

**Migration**:
```bash
mkdir -p docs/{getting-started,development,operations,reference}
git mv QUICKSTART.md docs/getting-started/
git mv SETUP_GUIDE.md docs/getting-started/
git mv TROUBLESHOOTING.md docs/operations/
git mv ARCHITECTURE.md docs/development/
```

### 2. Consolidate Git Documentation

**Current Issue**: Two similar files:
- `GITHUB_PUSH.md`
- `GITHUB_PUSH_GUIDE.md`

**Proposed Solution**:

Create single `docs/development/GIT_WORKFLOW.md`:

```markdown
# Git Workflow Guide

## Quick Reference
[Content from GITHUB_PUSH.md]

## Detailed Guide
[Content from GITHUB_PUSH_GUIDE.md]

## Troubleshooting Git Issues
[Additional content]
```

**Migration**:
```bash
# Merge files
cat GITHUB_PUSH.md GITHUB_PUSH_GUIDE.md > docs/development/GIT_WORKFLOW.md
# Edit to remove duplicates
git rm GITHUB_PUSH.md GITHUB_PUSH_GUIDE.md
```

### 3. Add GitHub Configuration

#### Create `.github/` Directory

```
.github/
├── workflows/
│   ├── build-test.yml
│   ├── docker-build.yml
│   └── documentation.yml
├── ISSUE_TEMPLATE/
│   ├── bug_report.md
│   ├── feature_request.md
│   └── question.md
├── PULL_REQUEST_TEMPLATE.md
└── CODEOWNERS
```

#### Example: `.github/workflows/build-test.yml`

```yaml
name: Build and Test

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-22.04
    steps:
      - uses: actions/checkout@v3
      - name: Build Docker image
        run: docker build -t tt-wormhole-e75:test .
      - name: Test Makefile
        run: docker run tt-wormhole-e75:test make help
```

#### Example: `.github/ISSUE_TEMPLATE/bug_report.md`

```markdown
---
name: Bug Report
about: Report a bug or issue
title: '[BUG] '
labels: bug
---

## Description
[Clear description of the bug]

## Environment
- OS: [e.g., Ubuntu 22.04]
- Docker version: [e.g., 20.10.21]
- Hardware: [e.g., Grayskull e75 or e150]

## Steps to Reproduce
1.
2.
3.

## Expected Behavior
[What should happen]

## Actual Behavior
[What actually happens]

## Logs
```
[Paste relevant logs]
```

## Additional Context
[Any other relevant information]
```

### 4. Add CONTRIBUTING.md

```markdown
# Contributing Guide

## Development Setup

1. Fork the repository
2. Clone your fork
3. Open in VS Code and reopen in container
4. Make your changes
5. Test thoroughly
6. Submit pull request

## Code Standards

- Follow existing code style
- Add tests for new features
- Update documentation
- Run `make smoke-silicon` before submitting

## Commit Messages

Format: `<type>(<scope>): <subject>`

Types:
- feat: New feature
- fix: Bug fix
- docs: Documentation
- style: Formatting
- refactor: Code restructuring
- test: Tests
- chore: Maintenance

Examples:
- `feat(makefile): add ccache support`
- `fix(dockerfile): correct python version`
- `docs(readme): add architecture diagrams`

## Pull Request Process

1. Update documentation
2. Add/update tests
3. Ensure all tests pass
4. Request review from maintainers
5. Address feedback
6. Merge when approved
```

### 5. Improve Makefile Documentation

#### Create `docs/reference/MAKEFILE_REFERENCE.md`

```markdown
# Makefile Reference

Complete reference for all Makefile targets, variables, and usage patterns.

## Targets

### Build Targets
...

### Test Targets
...

### Utility Targets
...

## Variables
...

## Advanced Usage
...

## Troubleshooting
...
```

### 6. Add Development Tools Configuration

#### Create `.editorconfig`

```ini
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true

[*.{py,sh}]
indent_style = space
indent_size = 4

[Makefile]
indent_style = tab

[*.{yml,yaml,json}]
indent_style = space
indent_size = 2

[*.md]
trim_trailing_whitespace = false
```

#### Create `.dockerignore`

```
.git
.github
.vscode
*.md
docs/
pybuda-build-helper/
scripts/
tt-budabackend/
*.lock
```

### 7. Add Testing Infrastructure

#### Create `tests/` Directory

```
tests/
├── unit/
│   └── test_environment.py
├── integration/
│   └── test_build.py
└── smoke/
    └── test_silicon.sh
```

#### Example: `tests/smoke/test_silicon.sh`

```bash
#!/bin/bash
set -euo pipefail

echo "Running smoke tests..."

# Test 1: Device visibility
echo "✓ Checking devices..."
ls /dev/tenstorrent/* > /dev/null

# Test 2: Build exists
echo "✓ Checking build..."
test -f tt-budabackend/build/lib/libdevice.so

# Test 3: Silicon test
echo "✓ Running silicon test..."
make smoke-silicon

echo "All smoke tests passed!"
```

### 8. Improve Scripts Organization

#### Reorganize `scripts/` Directory

```
scripts/
├── setup/
│   ├── verify_environment.sh
│   └── first_build.sh
├── build/
│   └── clean_rebuild.sh
├── test/
│   └── run_tests.sh
└── utils/
    ├── backup.sh
    └── cleanup.sh
```

### 9. Add Docker Compose Support

#### Create `docker-compose.yml`

```yaml
version: '3.8'

services:
  dev:
    build:
      context: .
      dockerfile: Dockerfile
    privileged: true
    cap_add:
      - IPC_LOCK
      - SYS_ADMIN
    devices:
      - /dev/tenstorrent:/dev/tenstorrent
    volumes:
      - .:/work
      - build-cache:/work/tt-budabackend/build
    environment:
      - ARCH_NAME=grayskull
      - TT_BACKEND_TIMEOUT=3600
    working_dir: /work
    command: bash

volumes:
  build-cache:
```

**Benefits**:
- Alternative to Dev Containers
- Easier for CI/CD
- Volume caching for faster rebuilds

### 10. Add Release Management

#### Create `CHANGELOG.md`

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- Mermaid diagrams in README
- ARCHITECTURE.md documentation
- IMPROVEMENTS.md suggestions

## [1.0.0] - 2025-10-23

### Added
- Initial repository structure
- Docker container configuration
- Makefile build system
- PyBuda build helper scripts
- Documentation suite
```

#### Create `.github/workflows/release.yml`

```yaml
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: ubuntu-22.04
    steps:
      - uses: actions/checkout@v3
      - name: Create Release
        uses: actions/create-release@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          tag_name: ${{ github.ref }}
          release_name: Release ${{ github.ref }}
          body_path: CHANGELOG.md
```

## Implementation Priority

### Phase 1: Critical (Immediate)
1. ✅ Add ARCHITECTURE.md (COMPLETED)
2. ✅ Add mermaid diagrams to README (COMPLETED)
3. Add CONTRIBUTING.md
4. Consolidate Git documentation

### Phase 2: Important (Next Sprint)
1. Reorganize docs/ directory
2. Add .github/ templates
3. Add .editorconfig and .dockerignore
4. Add tests/ infrastructure

### Phase 3: Enhancement (Future)
1. GitHub Actions CI/CD
2. Docker Compose support
3. Release management workflow
4. Expanded test coverage

## Migration Checklist

- [ ] Create new directory structure
- [ ] Move existing files to new locations
- [ ] Update all cross-references in documentation
- [ ] Update README with new paths
- [ ] Test all make targets still work
- [ ] Update .devcontainer paths if needed
- [ ] Commit changes with clear message
- [ ] Update any external links/bookmarks

## Benefits Summary

| Improvement | Benefit | Effort |
|-------------|---------|--------|
| docs/ organization | Better navigation | Medium |
| Git doc consolidation | Reduced confusion | Low |
| .github/ templates | Improved collaboration | Medium |
| CONTRIBUTING.md | Clear guidelines | Low |
| CI/CD workflows | Automated testing | High |
| Docker Compose | Alternative deployment | Low |
| Testing infrastructure | Better quality | High |
| Release management | Professional releases | Medium |

## Backward Compatibility

All improvements maintain backward compatibility:
- Old documentation paths redirect/symlink
- Makefile targets unchanged
- Docker configuration compatible
- No breaking changes to workflow

## Next Steps

1. Review this document with team
2. Prioritize improvements
3. Create implementation plan
4. Execute in phases
5. Update as repository evolves

---

**Document Version**: 1.0
**Created**: 2025-11-14
**Author**: Claude (AI Assistant)
**Status**: Proposal for Review
