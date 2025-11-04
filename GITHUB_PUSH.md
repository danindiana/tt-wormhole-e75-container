# Pushing to GitHub

This repository is ready to be pushed to GitHub for sharing and backup.

## Create GitHub Repository

1. Go to https://github.com/new
2. Repository name: `tenstorrent-greyskull-dev` (or your preferred name)
3. Description: `Docker dev environment for Tenstorrent Greyskull e150 with VS Code integration`
4. **Keep it Private** (contains hardware-specific configuration)
5. **Do NOT initialize** with README, .gitignore, or license (we already have these)
6. Click "Create repository"

## Push to GitHub

```bash
cd ~/programs/tenstorrent-greyskull-dev_20251023_031811

# Add remote (replace YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/tenstorrent-greyskull-dev.git

# Push all commits and tags
git push -u origin master
git push --tags

# Verify
git remote -v
```

## Clone on Another Machine

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/tenstorrent-greyskull-dev.git
cd tenstorrent-greyskull-dev

# Checkout the verified working version
git checkout v1.0-working

# Open in VS Code
code .

# In VS Code: Ctrl+Shift+P → "Dev Containers: Reopen in Container"
# Wait for container to build (~5 minutes)

# Inside container:
make clone
make build_hw
make smoke-silicon
```

## What Gets Pushed

✅ **Included in repository:**
- Configuration files (Dockerfile, devcontainer.json, Makefile)
- Helper scripts (4 bash scripts)
- Documentation (README, QUICKSTART, SETUP_GUIDE, TROUBLESHOOTING, SUMMARY)
- Git metadata (.git directory)
- .gitignore rules

❌ **NOT included (in .gitignore):**
- tt-budabackend/ directory (clone fresh each time)
- Build artifacts (build/, tt_build/)
- Test results (scripts/test_results_*)
- VS Code workspace files (.vscode/*)
- Container-specific files

## Why Clone Fresh?

The `tt-budabackend` repository (~1GB) is not stored in git:
- **Reason 1**: Size - Keeps this repo small and fast to clone
- **Reason 2**: Licensing - tt-budabackend has its own license
- **Reason 3**: Updates - Easy to get latest version or pin specific commits
- **Reason 4**: Clean builds - Each developer starts fresh

The Makefile handles cloning automatically:
```bash
make clone  # Clones at pinned commit e4e03c8c
```

## Repository Structure After Clone

```
Your Machine:
  tenstorrent-greyskull-dev/       ← Small repo (20 files, ~500KB)
  ├── Dockerfile
  ├── .devcontainer/
  ├── Makefile
  ├── scripts/
  └── docs (README, etc.)

After `make clone`:
  tenstorrent-greyskull-dev/
  └── tt-budabackend/              ← Downloaded separately (~1GB)
      ├── src/
      ├── umd/
      └── third_party/
```

## Security Notes

### Keep Private if:
- Contains proprietary configuration
- Includes hardware-specific settings
- Used for internal development

### Can Make Public if:
- Remove any proprietary comments
- Keep as educational/reference material
- Helpful for other Greyskull e150 users

## Collaboration

Share repository URL with team members:
```
git clone https://github.com/YOUR_USERNAME/tenstorrent-greyskull-dev.git
```

They'll need:
- Docker installed and user in docker group
- VS Code with Dev Containers extension
- Tenstorrent Greyskull e150 hardware (optional for testing)

## Updating Repository

After making changes:
```bash
# Check status
git status

# Stage changes
git add <files>

# Commit
git commit -m "Description of changes"

# Push
git push

# Tag new working versions
git tag -a v1.1-working -m "Description"
git push --tags
```

## Rollback to Working State

If something breaks:
```bash
# Go back to verified version
git checkout v1.0-working

# Or create a new branch to test changes
git checkout -b experimental v1.0-working
```

## Repository Stats

- **Size**: ~500KB (without tt-budabackend)
- **Commits**: 8
- **Tags**: v1.0-working
- **Files**: 20
- **Documentation**: 1,500+ lines
- **Time to clone**: <5 seconds
- **Time to full setup**: ~20 minutes

---

**Ready to push!** The repository is complete, documented, and verified working.
