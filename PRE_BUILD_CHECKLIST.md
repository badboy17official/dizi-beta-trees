# Dizi ROM Build - Pre-Build Checklist

## Repository Status

### Device Tree: android_device_xiaomi_dizi
- [x] Core configuration files created
- [x] Vendor blob list (proprietary-files.txt) - 328 entries
- [x] Device makefiles (lineage_dizi.mk, device.mk, BoardConfig.mk)
- [x] Overlay configurations
- [x] Init scripts (init.dizi.rc)
- [x] SELinux policies
- [x] Kernel config (dizi_GKI.config)
- [x] Kernel device tree overlays (in kernel_dtsi/)
- [ ] **Repository pushed to GitHub (M0Rf30/android_device_xiaomi_dizi)**

### Vendor Blobs: vendor_xiaomi_dizi
- [x] 168 vendor blobs extracted
- [x] Vendor makefiles created
- [x] Blob organization structure
- [ ] **Repository pushed to GitHub (M0Rf30/vendor_xiaomi_dizi)**

### Kernel: android_kernel_xiaomi_sm7435
- [x] Kernel config created (dizi_GKI.config)
- [ ] **Fork LineageOS repo to M0Rf30**
- [ ] **Copy dizi_GKI.config to arch/arm64/configs/vendor/**
- [ ] **Commit and push**

### Kernel Modules: android_kernel_xiaomi_sm7435-modules
- [x] Verified qca_cld3_qca6750.ko exists
- [x] Verified FM Radio driver exists
- [ ] **Fork LineageOS repo to M0Rf30**
- [ ] **No changes needed (uses existing modules)**
- [ ] **Push fork**

### Kernel Device Trees: android_kernel_xiaomi_sm7435-devicetrees
- [x] Device tree overlays created
- [ ] **Fork LineageOS repo to M0Rf30**
- [ ] **Copy dizi-sm7435.dtsi to qcom/**
- [ ] **Copy dizi-pinctrl.dtsi to qcom/**
- [ ] **Copy dizi-camera-sensor-qrd.dtsi to qcom/camera/**
- [ ] **Create parrotp-qrd-dizi.dts**
- [ ] **Update Makefile**
- [ ] **Commit and push**

---

## Pre-Build Actions

### 1. Push Device Tree to GitHub

```bash
cd /home/gianluca/android_device_xiaomi_dizi

# Initialize git if not already done
git init
git checkout -b lineage-23.0

# Add all files
git add .

# Create .gitignore
cat > .gitignore << 'EOF'
# Build artifacts
*.o
*.ko
*.dtb
*.dtbo

# Temporary files
*~
*.swp

# IDE files
.vscode/
.idea/

# Kernel dtsi working directory (these go in kernel repo)
kernel_dtsi/

# Local testing
test/
EOF

git add .gitignore

# Commit
git commit -m "dizi: Initial LineageOS 23.0 device tree for POCO Pad

Device specifications:
- Codename: dizi
- Model: 2405CPCFBG (POCO Pad)
- SoC: Qualcomm SM7435P (Parrot)
- Display: 12.1\" WQXGA (2560x1600) IPS LCD
- RAM: 8GB LPDDR4X
- Storage: 256GB UFS 2.2
- WiFi: WCN6750 (802.11ax)
- Bluetooth: 5.2
- FM Radio: RTC6226
- Cameras: 8MP rear (GC08A3), 8MP front (OV08D10)
- Battery: 10000mAh
- USB: Type-C 2.0, OTG support
- Audio: Quad stereo speakers

Key features:
- Tablet form factor optimizations
- Hall sensor for lid detection
- No cellular modem
- No fingerprint sensor
- No IR blaster

Based on: LineageOS device tree for Xiaomi Garnet (Redmi Note 13 Pro 5G)
"

# Add remote and push
git remote add origin https://github.com/M0Rf30/android_device_xiaomi_dizi.git
git push -u origin lineage-23.0
```

### 2. Push Vendor Blobs to GitHub

```bash
cd /home/gianluca/vendor_xiaomi_dizi

git init
git checkout -b lineage-23.0
git add .

# Create .gitignore
cat > .gitignore << 'EOF'
# Extraction scripts working files
*.log
extract_output/
EOF

git add .gitignore

git commit -m "dizi: Initial vendor blobs for POCO Pad

168 vendor blobs extracted from stock firmware:
- OS version: OS2.0.207.0.VNSEUXM (Android 15)
- Region: EEA Global
- Build date: 2025-01-12

Key vendor files:
- WCN6750 WiFi/BT firmware and configs
- FM Radio binaries (RTC6226)
- Camera sensor libraries (GC08A3, OV08D10)
- ACDB audio calibration (parrot_qrd)
- Display and touch firmware

Note: 95 blobs from proprietary-files.txt are provided by
LineageOS HAL implementations and not included here.
"

git remote add origin https://github.com/M0Rf30/vendor_xiaomi_dizi.git
git push -u origin lineage-23.0
```

### 3. Fork and Update Kernel Repositories

#### A. Fork on GitHub
Visit these URLs and click "Fork":
1. https://github.com/LineageOS/android_kernel_xiaomi_sm7435
2. https://github.com/LineageOS/android_kernel_xiaomi_sm7435-modules
3. https://github.com/LineageOS/android_kernel_xiaomi_sm7435-devicetrees

#### B. Clone and Update Kernel

```bash
cd ~/kernel_work
git clone https://github.com/M0Rf30/android_kernel_xiaomi_sm7435.git
cd android_kernel_xiaomi_sm7435

git checkout -b lineage-23.0-dizi

# Copy kernel config
cp /home/gianluca/android_device_xiaomi_dizi/dizi_GKI.config \
   arch/arm64/configs/vendor/

git add arch/arm64/configs/vendor/dizi_GKI.config
git commit -m "dizi: Add kernel configuration for POCO Pad

Key configs enabled:
- CONFIG_CNSS_QCA6750=y (WCN6750 WiFi)
- CONFIG_BT_WCNSS_QCA6750=y (WCN6750 Bluetooth)
- CONFIG_RADIO_RTC6226=y (FM Radio)
- Camera sensor configs (GC08A3, OV08D10)

Disabled phone-specific features:
- Fingerprint sensors
- IR blaster

Based on: parrot_GKI.config
Device: Xiaomi Dizi (POCO Pad)
"

git push origin lineage-23.0-dizi
```

#### C. Update Kernel Modules (No Changes Needed)

```bash
cd ~/kernel_work
git clone https://github.com/M0Rf30/android_kernel_xiaomi_sm7435-modules.git
cd android_kernel_xiaomi_sm7435-modules

# Just verify qca6750 module exists
ls -la qcacld-3.0/.qca6750/
# Should show qca_cld3_qca6750.ko and related files

# No changes needed, just push the fork
git checkout -b lineage-23.0
git push origin lineage-23.0
```

#### D. Update Kernel Device Trees

```bash
cd ~/kernel_work
git clone https://github.com/M0Rf30/android_kernel_xiaomi_sm7435-devicetrees.git
cd android_kernel_xiaomi_sm7435-devicetrees

git checkout -b lineage-23.0-dizi

# Copy device tree files
cp /home/gianluca/android_device_xiaomi_dizi/kernel_dtsi/dizi-sm7435.dtsi \
   qcom/

cp /home/gianluca/android_device_xiaomi_dizi/kernel_dtsi/dizi-pinctrl.dtsi \
   qcom/

mkdir -p qcom/camera
cp /home/gianluca/android_device_xiaomi_dizi/kernel_dtsi/dizi-camera-sensor-qrd.dtsi \
   qcom/camera/

# Create DTS compilation target
cat > qcom/parrotp-qrd-dizi.dts << 'EOF'
/dts-v1/;
/plugin/;

#include "parrotp.dtsi"
#include "parrotp-qrd.dtsi"
#include "dizi-sm7435.dtsi"
#include "camera/dizi-camera-sensor-qrd.dtsi"

/ {
    model = "Qualcomm Technologies, Inc. Parrot QRD, DIZI";
    compatible = "qcom,parrotp-qrd", "qcom,parrotp", "qcom,qrd";
    qcom,msm-id = <638 0x10000>;
    qcom,board-id = <0x2000B 1>;
};
EOF

# Update Makefile - add dizi target
# Find the line with "dtbo-$(CONFIG_ARCH_PARROT)" and add:
echo "dtbo-\$(CONFIG_ARCH_PARROT) += parrotp-qrd-dizi.dtbo" >> qcom/Makefile

git add qcom/dizi-sm7435.dtsi
git add qcom/dizi-pinctrl.dtsi
git add qcom/camera/dizi-camera-sensor-qrd.dtsi
git add qcom/parrotp-qrd-dizi.dts
git add qcom/Makefile

git commit -m "dizi: Add device tree overlays for POCO Pad

Device tree files:
- dizi-sm7435.dtsi: Main device configuration
  * FM Radio (RTC6226) on I2C 0x64, GPIO 105
  * Hall sensor (lid detect) on GPIO 65
  * WiFi/BT (WCN6750) with power rails
  * USB OTG configuration
  * Tablet-specific audio (stereo speakers)
  * Display panel (WQXGA 2560x1600)
  * Thermal zones
  * Storage (eMMC, SD card)

- dizi-pinctrl.dtsi: GPIO pin configurations
  * FM Radio INT: GPIO 105
  * Hall sensor: GPIO 65  
  * Camera sensors: GPIOs 39,40,44,45
  * Volume key: PMK8350 GPIO1

- camera/dizi-camera-sensor-qrd.dtsi: Camera setup
  * Rear: GC08A3 8MP on CCI0 Master0, CSI PHY0
  * Front: OV08D10 8MP on CCI0 Master1, CSI PHY2

- parrotp-qrd-dizi.dts: Build target
  * Board ID: 0x2000B
  * MSM ID: 638 (SM7435P)

Device: Xiaomi Dizi (POCO Pad, model 2405CPCFBG)
"

git push origin lineage-23.0-dizi
```

---

## Build Environment Setup

### 4. Create Local Manifest

```bash
cd ~/android/lineage
mkdir -p .repo/local_manifests

cat > .repo/local_manifests/dizi.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
    <!-- Device tree -->
    <project name="M0Rf30/android_device_xiaomi_dizi" 
             path="device/xiaomi/dizi" 
             remote="github" 
             revision="lineage-23.0" />
    
    <!-- Vendor blobs -->
    <project name="M0Rf30/vendor_xiaomi_dizi" 
             path="vendor/xiaomi/dizi" 
             remote="github" 
             revision="lineage-23.0" />
    
    <!-- Kernel -->
    <project name="M0Rf30/android_kernel_xiaomi_sm7435" 
             path="kernel/xiaomi/sm7435" 
             remote="github" 
             revision="lineage-23.0-dizi" />
    
    <!-- Kernel modules -->
    <project name="M0Rf30/android_kernel_xiaomi_sm7435-modules" 
             path="kernel/xiaomi/sm7435-modules" 
             remote="github" 
             revision="lineage-23.0" />
    
    <!-- Kernel device trees -->
    <project name="M0Rf30/android_kernel_xiaomi_sm7435-devicetrees" 
             path="kernel/xiaomi/sm7435-devicetrees" 
             remote="github" 
             revision="lineage-23.0-dizi" />
</manifest>
EOF
```

### 5. Sync Repositories

```bash
cd ~/android/lineage
repo sync -c -j$(nproc --all)
```

---

## Build Process

### 6. Initialize Build Environment

```bash
cd ~/android/lineage
source build/envsetup.sh
breakfast dizi
```

**Expected Output:**
```
Looking for dependencies in device/xiaomi/dizi
Looking for dependencies in device/qcom/common
...
Dependencies file not found, bailing out.

============================================
PLATFORM_VERSION_CODENAME=VanillaIceCream
PLATFORM_VERSION=15
LINEAGE_VERSION=23.0-20260112-UNOFFICIAL-dizi
...
============================================
```

### 7. Start Build

```bash
# Clean build (first time)
mka clean
mka clobber

# Build boot image first (test kernel)
mka bootimage

# If bootimage succeeds, build full ROM
mka bacon
```

**Build Time Estimate:**
- Boot image: 30-60 minutes
- Full ROM: 2-4 hours (depending on CPU cores)

---

## Post-Build Verification

### 8. Check Build Artifacts

```bash
cd ~/android/lineage/out/target/product/dizi

# Verify key files exist
ls -lh | grep -E "boot.img|recovery.img|system.img|vendor.img|lineage.*\.zip"

# Check DTB/DTBO
ls -lh obj/KERNEL_OBJ/arch/arm64/boot/dts/vendor/qcom/ | grep dizi

# Expected:
# - boot.img (kernel + ramdisk)
# - recovery.img (recovery image)
# - system.img (system partition)
# - vendor.img (vendor partition)  
# - lineage-23.0-20260112-UNOFFICIAL-dizi.zip (flashable ROM)
# - parrotp-qrd-dizi.dtb
# - parrotp-qrd-dizi.dtbo
```

### 9. Extract and Verify Boot Image

```bash
# Extract boot.img
cd ~/android/lineage/out/target/product/dizi
mkdir boot_extract
cd boot_extract

# Use unpackbootimg or similar tool
python3 ~/android/lineage/tools/mkbootimg/unpack_bootimg.py \
    --boot_img ../boot.img \
    --out .

# Check kernel cmdline
cat args

# Should contain:
# - androidboot.hardware=qcom
# - androidboot.selinux=permissive (for first boot testing)
```

---

## Installation Preparation

### 10. Device Preparation

**On the device:**
1. [ ] Backup all data
2. [ ] Enable USB debugging
3. [ ] Enable OEM unlocking
4. [ ] Unlock bootloader (if not already unlocked)

**Unlock command:**
```bash
adb reboot bootloader
fastboot oem unlock
# Or: fastboot flashing unlock
```

### 11. Flash Custom Recovery (Optional but Recommended)

```bash
# Boot TWRP temporarily (recommended for first flash)
fastboot boot twrp-3.7.0_12-dizi.img

# Or flash permanently
fastboot flash recovery twrp-3.7.0_12-dizi.img
```

---

## Installation Methods

### Method 1: Fastboot Flash (Recommended for Testing)

```bash
cd ~/android/lineage/out/target/product/dizi

# Reboot to bootloader
adb reboot bootloader

# Flash individual partitions
fastboot flash boot boot.img
fastboot flash dtbo dtbo.img
fastboot flash vendor_boot vendor_boot.img
fastboot flash system system.img
fastboot flash vendor vendor.img

# Wipe userdata (WILL ERASE ALL DATA)
fastboot -w

# Reboot
fastboot reboot
```

### Method 2: Recovery Flash (Recommended for Updates)

```bash
# Copy ROM to device
adb push lineage-23.0-20260112-UNOFFICIAL-dizi.zip /sdcard/

# Reboot to recovery
adb reboot recovery

# In recovery:
# 1. Wipe > Format Data
# 2. Wipe > Advanced Wipe > System, Cache, Dalvik
# 3. Install > Select lineage...zip
# 4. Reboot System
```

---

## First Boot Testing

### 12. Monitor First Boot

```bash
# Connect via ADB during boot
adb logcat -v time > first_boot.log &
adb shell dmesg > kernel_boot.log &

# Watch for critical errors
adb logcat | grep -iE "error|fatal|crash"
```

**Expected Boot Time:** 2-5 minutes (first boot is slower)

### 13. Hardware Test Checklist

After successful boot:

**Basic Functionality:**
- [ ] Device boots to launcher
- [ ] Touch screen responsive
- [ ] Display brightness adjustable
- [ ] Sound from speakers
- [ ] WiFi connects to network
- [ ] Bluetooth pairs with device

**Dizi-Specific:**
- [ ] FM Radio app detects tuner
- [ ] Hall sensor: closing lid turns off screen
- [ ] Both cameras work (front and rear)
- [ ] USB data transfer works
- [ ] SD card detected and mounted
- [ ] Volume buttons work
- [ ] Battery percentage shows correctly

**Test Commands:**
```bash
# FM Radio device
adb shell ls -l /dev/radio0

# Hall sensor
adb shell getevent -lc /dev/input/event* | grep -i lid

# Cameras
adb shell cat /sys/kernel/debug/camera/sensor

# WiFi chipset
adb shell getprop | grep wifi

# Kernel version
adb shell uname -a

# SELinux status
adb shell getenforce
```

---

## Known Issues Tracking

### 14. Create Issues Document

After first boot, document any issues:

```bash
cd /home/gianluca/android_device_xiaomi_dizi
cat > KNOWN_ISSUES.md << 'EOF'
# Known Issues - Dizi LineageOS 23.0

## Build 20260112-UNOFFICIAL

### Critical Issues
- [ ] None yet

### Major Issues
- [ ] None yet

### Minor Issues
- [ ] None yet

### To Be Tested
- [ ] FM Radio functionality
- [ ] Hall sensor (lid detection)
- [ ] Camera quality and performance
- [ ] WiFi stability (2.4GHz and 5GHz)
- [ ] Bluetooth audio quality
- [ ] Battery life
- [ ] Thermal management
- [ ] USB OTG devices
- [ ] SD card performance

### Hardware Not Working
- N/A - Telephony (device has no modem)
- N/A - Fingerprint (device has no sensor)
- N/A - IR blaster (device has no IR)
EOF
```

---

## Success Criteria

Build is considered successful if:
- [x] All repositories pushed to GitHub
- [ ] ROM compiles without errors
- [ ] Boot image created successfully
- [ ] Device boots to Android launcher
- [ ] Touch screen works
- [ ] WiFi connects
- [ ] Audio output works
- [ ] At least one camera works

---

## Rollback Plan

If build fails or device doesn't boot:

### Return to Stock

```bash
# Flash stock firmware
# Download: OS2.0.207.0.VNSEUXM from Xiaomi

# Use MiFlash tool or fastboot:
fastboot flash partition gpt_both0.bin
fastboot flash xbl xbl.elf
fastboot flash xbl_config xbl_config.elf
fastboot flash abl abl.elf
# ... (continue with all partitions from stock ROM)

# Or use MiFlash "Clean All" option
```

---

## Next Steps After Successful Build

1. [ ] Create GitHub release with ROM zip
2. [ ] Write installation guide for users
3. [ ] Create XDA forum thread
4. [ ] Submit to LineageOS for review (if quality sufficient)
5. [ ] Set up Jenkins/CI for automated builds
6. [ ] Create OTA update system
7. [ ] Document any device-specific quirks

---

## Emergency Contacts

**LineageOS Community:**
- IRC: #lineageos on libera.chat
- Telegram: @LineageOS
- Reddit: r/LineageOS

**Qualcomm Tools:**
- QPST (for low-level recovery)
- EDL mode access (Vol- + Power while connecting USB)

---

## Completion Checklist

Before declaring "build ready":

- [ ] All git repositories created and pushed
- [ ] Local manifest created
- [ ] Repositories synced successfully
- [ ] `breakfast dizi` runs without errors
- [ ] Kernel config found and used
- [ ] Device tree overlays compiled
- [ ] Boot image builds successfully
- [ ] Full ROM builds successfully
- [ ] ROM size reasonable (< 2GB)
- [ ] All critical partitions present in out/

---

**Created:** 2026-01-12  
**Last Updated:** 2026-01-12  
**Status:** Pre-build preparation  
**Next Action:** Push repositories to GitHub
