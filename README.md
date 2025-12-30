# OpenWrt ImageBuilder for MX4200 V1 (AP Mode)

This project builds custom OpenWrt firmware for the Linksys MX4200 V1 configured as an Access Point.

## Directory Structure

```
├── configs/           # Device-specific configurations
├── packages/          # Custom packages and package lists
├── scripts/           # Additional utility scripts (if needed)
├── files/             # Files to be included in the firmware
│   ├── etc/
│   │   ├── config/    # UCI configuration files
│   │   └── uci-defaults/ # First-boot configuration scripts
├── docs/              # Documentation
└── Makefile           # Build automation
```

## Quick Start

1. **GitHub Actions Build (Recommended):**
   ```bash
   git push origin master
   ```
   - Go to Actions tab in GitHub
   - Download firmware from build artifacts

2. **Local Build (Linux only):**
   ```bash
   make all
   ```

3. **Individual Steps:**
   ```bash
   make download    # Download ImageBuilder
   make verify      # Verify checksum
   make extract     # Extract archive
   make build       # Build firmware
   ```

4. **Check Status:**
   ```bash
   make status
   ```

## Available Make Targets

- `make all` - Complete build process (download → verify → extract → build)
- `make download` - Download ImageBuilder archive
- `make verify` - Verify SHA256 checksum
- `make extract` - Extract ImageBuilder
- `make build` - Build firmware image
- `make clean` - Remove build artifacts
- `make distclean` - Remove everything
- `make status` - Show current status
- `make help` - Show all available commands

## Configuration

The firmware is pre-configured for AP mode with optimized settings for the MX4200 V1 hardware.