# Redmi Pad Pro (dizi) – LineageOS Bring-Up

## 📱 Device Information

- **Device Name:** Redmi Pad Pro  
- **Codename:** dizi  
- **SoC:** Qualcomm SM7435  
- **Android Base:** LineageOS 23 (Android 16)  
- **Kernel Type:** GKI (Generic Kernel Image)

---

# 📌 Project Status

This repository contains the early bring-up work for Redmi Pad Pro (dizi) on LineageOS.

The project has migrated from an attempted monolithic kernel build to a proper GKI-based setup.

---

# 🧠 Initial Kernel Attempt (Abandoned)

## What Was Attempted

- Integrated SM7435 kernel source
- Used:
  TARGET_KERNEL_SOURCE := kernel/xiaomi/sm7435  
  TARGET_KERNEL_CONFIG := gki_defconfig  
  TARGET_KERNEL_EXT_MODULE_ROOT := kernel/xiaomi/sm7435-modules  

## Problems Encountered

- No device-specific DTS present
- Kernel generated unrelated upstream DTBs
- Missing vendor DTBs
- Module packaging failures
- Recovery module mismatches
- DTB move errors
- Kernel not aligned with modern Xiaomi GKI architecture

## Conclusion

Redmi Pad Pro is a **GKI-based device**.  
Full kernel compilation from source is incorrect for this device.

---

# 🔄 Migration to Proper GKI Setup

## BoardConfig Changes

Commented out:

```make
# TARGET_KERNEL_SOURCE := kernel/xiaomi/sm7435
# TARGET_KERNEL_CONFIG := gki_defconfig
# TARGET_KERNEL_EXT_MODULE_ROOT := kernel/xiaomi/sm7435-modules
```

Added:

```make
BOARD_USES_GENERIC_KERNEL_IMAGE := true

BOARD_PREBUILT_BOOTIMAGE := device/xiaomi/dizi/prebuilt/boot.img
BOARD_PREBUILT_VENDOR_BOOTIMAGE := device/xiaomi/dizi/prebuilt/vendor_boot.img
BOARD_PREBUILT_DTBOIMAGE := device/xiaomi/dizi/prebuilt/dtbo.img
```

---

# 🔐 SELinux Progress

Fixed:

- Duplicate `radio_device` declaration
- Removed forbidden capabilities:
  - dac_override
  - dac_read_search
- Removed conflicting `/dev/radio0` file_context
- Cleaned vendor_fm_radio policy
- Fixed neverallow violations

SELinux now compiles cleanly under GKI configuration.

---

# 🧩 Kernel Module Cleanup

- Removed references to missing `.ko` modules
- Cleaned modules.load lists
- Removed recovery module conflicts (gh_virt_wdt.ko)
- Eliminated unnecessary FM components

---

# 📂 Repository Structure

```
device/xiaomi/dizi/
 ├── BoardConfig.mk
 ├── device.mk
 ├── sepolicy/
 ├── modules/
 ├── prebuilt/   (stock kernel images go here)
```

---

# 📦 Required Stock Files

From official fastboot ROM:

- boot.img
- vendor_boot.img
- dtbo.img
- vendor_dlkm.img (recommended)

Place inside:

```
device/xiaomi/dizi/prebuilt/
```

---

# 🚀 Expected Build Behavior (After Prebuilts Added)

- No kernel compilation
- No DTB generation
- No module build
- Direct packaging using stock GKI kernel
- System + vendor image build only

---

# 📊 Current Status

| Component | Status |
|------------|--------|
| Device Tree | Structured |
| Kernel (Source Build) | Abandoned |
| GKI Migration | In Progress |
| SELinux | Clean |
| Module Cleanup | Completed |
| Prebuilt Integration | Pending |
| First Boot | Pending |

---

# 🎯 Next Steps

1. Extract required images from stock fastboot ROM
2. Add them to prebuilt/
3. Push using Git LFS (if files exceed 100MB)
4. Perform clean GKI build
5. Attempt first flash

---

# 🧠 Notes

Modern Xiaomi devices rely on:

- GKI base kernel
- vendor_boot image
- dtbo image
- vendor_dlkm modules

Monolithic kernel builds are not applicable.

---

Project is currently in early bring-up stage.
Further debugging and hardware validation pending.
