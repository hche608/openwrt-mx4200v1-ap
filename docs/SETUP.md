# MX4200 V1 AP Mode Setup Guide

## Prerequisites

- Linux or macOS system with build tools
- Internet connection for downloading ImageBuilder
- At least 2GB free disk space

## Building the Firmware

1. Clone or download this project
2. Run the build script:
   ```bash
   ./scripts/build.sh
   ```

## Installation

1. Connect to your MX4200 V1 via Ethernet
2. Access the web interface (usually http://192.168.1.1)
3. Upload the generated firmware file from `bin/targets/ipq807x/generic/`
4. Wait for the device to reboot

## Post-Installation Configuration

After flashing:

1. The device will be accessible at `192.168.1.2`
2. Default WiFi credentials:
   - 5GHz: `MX4200-5G` / `changeme123`
   - 2.4GHz: `MX4200-2G` / `changeme123`
3. Change the WiFi password via LuCI web interface
4. Configure your main router to use `192.168.1.1` as gateway

## AP Mode Features

- DHCP server disabled (relies on main router)
- Bridge mode for all LAN ports
- Optimized WiFi settings for AP operation
- Web management interface enabled

## Troubleshooting

- If the device doesn't boot, try recovery mode
- Check network cables and connections
- Verify the firmware file is for MX4200 V1 specifically