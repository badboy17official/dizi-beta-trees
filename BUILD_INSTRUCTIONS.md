# LineageOS Build Instructions for Xiaomi Dizi (POCO Pad)

## Overview
This document provides step-by-step instructions to build LineageOS for the Xiaomi Dizi (POCO Pad, model 2405CPCFBG) based on the Garnet (Redmi Note 13 Pro 5G) device tree with adaptations for Dizi-specific hardware.

## Prerequisites

### System Requirements
- 64-bit Linux distribution (Ubuntu 20.04 LTS or newer recommended)
- Minimum 16GB RAM (32GB recommended)
- Minimum 300GB free disk space (SSD recommended)
- Fast internet connection

### Required Packages
```bash
sudo apt-get install -y bc bison build-essential ccache curl flex \
    g++-multilib gcc-multilib git gnupg gperf imagemagick lib32ncurses5-dev \
    lib32readline-dev lib32z1-dev liblz4-tool libncurses5 libncurses5-dev \
    libsdl1.2-dev libssl-dev libxml2 libxml2-utils lzop pngcrush \
    rsync schedtool squashfs-tools xsltproc zip zlib1g-dev \
    openjdk-11-jdk python-is-python3
```

## Step 1: Sync LineageOS Source

### Initialize Repository
```bash
mkdir -p ~/android/lineage
cd ~/android/lineage
repo init -u https://github.com/LineageOS/android.git -b lineage-22.0 --git-lfs
```

### Create Local Manifest
Create `.repo/local_manifests/dizi.xml`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
    <!-- Device Tree -->
    <project name="YourGithub/android_device_xiaomi_dizi" 
             path="device/xiaomi/dizi" 
             remote="github" 
             revision="lineage-22.0" />
    
    <!-- Vendor Blobs -->
    <project name="YourGithub/vendor_xiaomi_dizi" 
             path="vendor/xiaomi/dizi" 
             remote="github" 
             revision="lineage-22.0" />
    
    <!-- Kernel -->
    <project name="LineageOS/android_kernel_xiaomi_sm7435" 
             path="kernel/xiaomi/sm7435" 
             remote="github" 
             revision="lineage-22.0" />
    
    <!-- Kernel Modules -->
    <project name="LineageOS/android_kernel_xiaomi_sm7435-modules" 
             path="kernel/xiaomi/sm7435-modules" 
             remote="github" 
             revision="lineage-22.0" />
    
    <!-- Hardware Xiaomi -->
    <project name="LineageOS/android_hardware_xiaomi" 
             path="hardware/xiaomi" 
             remote="github" 
             revision="lineage-22.0" />
</manifest>
```

### Sync Repositories
```bash
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
```

## Step 2: Copy Device Tree and Vendor Files

### Device Tree
```bash
# Copy device tree to LineageOS source
cp -r /home/gianluca/android_device_xiaomi_dizi ~/android/lineage/device/xiaomi/dizi
```

### Vendor Blobs
```bash
# Copy vendor blobs to LineageOS source
cp -r /home/gianluca/vendor_xiaomi_dizi ~/android/lineage/vendor/xiaomi/dizi
```

## Step 3: Kernel Configuration

### Create Dizi Kernel Config
Create file: `kernel/xiaomi/sm7435/arch/arm64/configs/vendor/dizi_GKI.config`

```makefile
# Based on garnet_GKI.config with Dizi modifications

# WiFi - WCN6750 (Dizi) vs WCN3990 (Garnet)
CONFIG_QCA_CLD_WLAN=m
CONFIG_QCA6750=y
CONFIG_CNSS_QCA6750=y
CONFIG_CNSS2=m
CONFIG_CNSS2_QMI=y
CONFIG_CNSS_UTILS=m

# Bluetooth - WCN6750
CONFIG_BT_QCA=m
CONFIG_BTFM_SLIM=m
CONFIG_BTFM_SLIM_WCN6750=y

# FM Radio - RTC6226 (Dizi specific)
CONFIG_RADIO_IRIS=y
CONFIG_RADIO_IRIS_TRANSPORT=m
CONFIG_I2C_RTC6226_QCA=m

# Camera - 2 sensors (vs 4 on Garnet)
CONFIG_GC08A3=y
CONFIG_OV08D10=y
CONFIG_MSMB_CAMERA=m

# Battery Authentication
CONFIG_AUTH_BATTERY=y

# Hall Sensor (lid detection)
CONFIG_SENSORS_HALL=y
CONFIG_INPUT_HALL_SENSOR=y
```

### Update Kernel Module Path
In `kernel/xiaomi/sm7435-modules/wlan/qca-wifi-host-cmn/Android.mk`:
```makefile
# Change from:
# LOCAL_MODULE := wlan.adrastea
# To:
LOCAL_MODULE := wlan.qca6750
```

## Step 4: Build Configuration

### Set Up Environment
```bash
cd ~/android/lineage
source build/envsetup.sh
```

### Select Build Target
```bash
breakfast dizi
# Or explicitly:
# lunch lineage_dizi-ap2a-userdebug
```

### Configure ccache (Optional but Recommended)
```bash
export USE_CCACHE=1
export CCACHE_EXEC=/usr/bin/ccache
ccache -M 50G  # Adjust size as needed
```

## Step 5: Build LineageOS

### Full Build
```bash
cd ~/android/lineage
source build/envsetup.sh
breakfast dizi
mka bacon
```

Build time: 2-6 hours depending on hardware

### Incremental Build (After Changes)
```bash
mka bacon -j$(nproc --all)
```

### Build Specific Modules
```bash
# Kernel only
mka bootimage

# System only
mka systemimage

# Vendor only
mka vendorimage
```

## Step 6: Flash LineageOS

### Install via Recovery

1. **Boot into Recovery** (TWRP or LineageOS Recovery)
   - Power off device
   - Hold Volume Up + Power until recovery appears

2. **Backup Current ROM** (Recommended)
   - TWRP: Backup > Select partitions > Swipe to backup

3. **Wipe Data**
   - TWRP: Wipe > Advanced Wipe > Select: Dalvik/ART, System, Data, Cache
   - LineageOS Recovery: Factory reset > Format data/factory reset

4. **Flash ROM**
   ```bash
   # Copy ROM to device
   adb push ~/android/lineage/out/target/product/dizi/lineage-*.zip /sdcard/
   
   # In recovery:
   # Install > Select lineage-*.zip > Swipe to confirm flash
   ```

5. **Flash GApps** (Optional)
   - Download MindTheGapps or NikGApps for ARM64
   - Flash immediately after ROM without rebooting

6. **Reboot**
   - Reboot > System

### Install via Fastboot (Advanced)

```bash
# Boot into fastboot mode
adb reboot bootloader

# Flash images
fastboot flash boot ~/android/lineage/out/target/product/dizi/boot.img
fastboot flash dtbo ~/android/lineage/out/target/product/dizi/dtbo.img
fastboot flash vendor_boot ~/android/lineage/out/target/product/dizi/vendor_boot.img
fastboot flash super ~/android/lineage/out/target/product/dizi/super_empty.img

# Erase userdata (first time only)
fastboot -w

# Reboot
fastboot reboot
```

## Expected Output Locations

After successful build:
```
~/android/lineage/out/target/product/dizi/
├── boot.img              # Kernel + ramdisk
├── dtbo.img              # Device tree overlay
├── vendor_boot.img       # Vendor ramdisk
├── super_empty.img       # Super partition (system+vendor)
├── lineage-*.zip         # Flashable ZIP
└── recovery.img          # Recovery image
```

## Troubleshooting

### Build Errors

**Error: "lunch: command not found"**
```bash
cd ~/android/lineage
source build/envsetup.sh
```

**Error: "FAILED: out/target/product/dizi/..."**
- Clean build:
  ```bash
  make clean
  mka bacon
  ```

**Error: WiFi module not loading**
- Verify BoardConfig.mk line 139: `LOCAL_MODULE := wlan.qca6750`
- Check modules.load has `qca_cld3_qca6750.ko`

**Error: Missing vendor blobs**
- Re-run extraction:
  ```bash
  sudo python3 /home/gianluca/vendor_xiaomi_dizi/extract_blobs.py
  ```

### Boot Issues

**Device bootloops**
1. Check kernel logs: `adb logcat -b kernel`
2. Verify DTB is correct for Dizi
3. Check SELinux is permissive (board-info.txt)

**WiFi not working**
1. Verify WCN6750 firmware in `/vendor/firmware/`
2. Check WiFi HAL service started: `adb shell ps -A | grep wifi`
3. Check kernel module loaded: `adb shell lsmod | grep qca6750`

**FM Radio not detected**
1. Verify rtc6226 module loaded: `lsmod | grep rtc6226`
2. Check init.dizi.rc has FM service entries
3. Verify FM blobs in vendor/lib64/

## Hardware Testing Checklist

After first boot, test all hardware:

- [ ] Display (brightness, touch, rotation)
- [ ] WiFi (2.4GHz and 5GHz)
- [ ] Bluetooth (pairing, audio)
- [ ] FM Radio (tune stations)
- [ ] Camera (front and rear)
- [ ] Audio (speakers, headphone jack if present)
- [ ] Battery (charging, percentage)
- [ ] Sensors (accelerometer, gyroscope, hall sensor)
- [ ] USB (charging, data transfer, OTG)
- [ ] GPS/Location
- [ ] Buttons (volume, power)
- [ ] SIM card detection (if applicable)

## Key Differences from Garnet

| Component | Garnet | Dizi |
|-----------|--------|------|
| **WiFi/BT** | WCN3990 (Adrastea) | WCN6750 |
| **FM Radio** | No | Yes (RTC6226) |
| **Camera** | 4 sensors | 2 sensors |
| **Device Type** | Phone | Tablet |
| **Hall Sensor** | No | Yes (lid detection) |
| **ACDB Path** | MTP | parrot_qrd |

## Files Modified from Garnet

### Critical Changes
1. **BoardConfig.mk:139** - WiFi module path: `.adrastea` → `.qca6750`
2. **device.mk:448-450** - WiFi config: `adrastea/` → `qca6750/`
3. **device.mk:155-161** - Added FM Radio packages
4. **proprietary-files.txt** - Updated for WCN6750 and FM Radio blobs
5. **modules/dlkm/modules.load** - `qca_cld3_adrastea.ko` → `qca_cld3_qca6750.ko`

## Additional Resources

- LineageOS Wiki: https://wiki.lineageos.org/devices/dizi/
- LineageOS Build Guide: https://wiki.lineageos.org/devices/dizi/build
- XDA Forum Thread: [Create after first successful build]
- GitHub Repositories:
  - Device tree: `YourGithub/android_device_xiaomi_dizi`
  - Vendor blobs: `YourGithub/vendor_xiaomi_dizi`
  - Kernel: `LineageOS/android_kernel_xiaomi_sm7435`

## Contributing

If you improve this ROM or fix issues:
1. Fork the repositories
2. Create feature branch: `git checkout -b feature/my-improvement`
3. Commit changes: `git commit -m "Add feature XYZ"`
4. Push to branch: `git push origin feature/my-improvement`
5. Create Pull Request on GitHub

## Credits

- LineageOS Team - Base ROM and build system
- Xiaomi - Original device trees and kernel
- Garnet Maintainers - Reference device tree
- Dizi Porting Team - Hardware adaptations and testing

## License

- Device tree: Apache 2.0
- Vendor blobs: Proprietary (extracted from stock ROM)
- LineageOS: Apache 2.0

---

**Last Updated:** January 12, 2026  
**LineageOS Version:** 22.0 (Android 15)  
**Stock ROM Base:** OS2.0.207.0.VNSEUXM (Dizi EEA Global)
