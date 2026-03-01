📄 Redmi Pad Pro (dizi) – LineageOS Bring-Up Progress
📌 Device Information

Device Name: Redmi Pad Pro

Codename: dizi

SoC: Qualcomm SM7435

Android Base: LineageOS 23 (Android 16)

Kernel Type: GKI (Generic Kernel Image)

🧠 Initial Phase – Kernel Attempt (Monolithic Build)
What Was Attempted

Cloned SM7435 kernel sources

Added:

TARGET_KERNEL_SOURCE := kernel/xiaomi/sm7435
TARGET_KERNEL_CONFIG := gki_defconfig
TARGET_KERNEL_EXT_MODULE_ROOT := kernel/xiaomi/sm7435-modules

Tried full kernel + DTB compilation

Issues Found

DTBs for actual device were not present.

Kernel built random upstream DTBs (msm899x, sdm845, etc.).

No sm7435 device-specific DTS found.

Packaging failed due to missing vendor DTBs.

Kernel modules mismatch errors.

Vendor boot module expectations failed.

Conclusion

Redmi Pad Pro is a modern GKI device.
Full kernel compilation is unnecessary and incorrect.

🔄 Migration To Proper GKI Setup
Decision

Switch from monolithic kernel build to:

Prebuilt stock kernel images

GKI configuration

Stock dtb/dtbo usage

⚙️ BoardConfig Changes
Commented Out:
# TARGET_KERNEL_SOURCE := kernel/xiaomi/sm7435
# TARGET_KERNEL_CONFIG := gki_defconfig
# TARGET_KERNEL_EXT_MODULE_ROOT := kernel/xiaomi/sm7435-modules
Added:
BOARD_USES_GENERIC_KERNEL_IMAGE := true

BOARD_PREBUILT_BOOTIMAGE := device/xiaomi/dizi/prebuilt/boot.img
BOARD_PREBUILT_VENDOR_BOOTIMAGE := device/xiaomi/dizi/prebuilt/vendor_boot.img
BOARD_PREBUILT_DTBOIMAGE := device/xiaomi/dizi/prebuilt/dtbo.img
🔐 SELinux Progress
Fixed Issues:

Removed duplicate radio_device declaration

Removed forbidden capabilities:

dac_override
dac_read_search

Removed conflicting /dev/radio0 file_context

Cleaned vendor_fm_radio policy

Result:
SELinux now compiles cleanly (pre-GKI migration stage).

🧩 Module Cleanup
Fixed:

Missing kernel modules load list

Removed references to non-built .ko files

Cleaned modules.load inconsistencies

Removed gh_virt_wdt.ko reference from recovery

📂 Repository Structure
device/xiaomi/dizi/
 ├── BoardConfig.mk
 ├── device.mk
 ├── sepolicy/
 ├── modules/
 ├── prebuilt/   (to contain stock images)
📦 Next Required Files (From Stock Fastboot ROM)

To complete GKI bring-up:

boot.img

vendor_boot.img

dtbo.img

vendor_dlkm.img (optional but recommended)

These will be placed in:

device/xiaomi/dizi/prebuilt/
🚀 Next Build Expectations

After adding stock prebuilts:

❌ No kernel compilation

❌ No DTB generation

❌ No module build

✅ Direct system/vendor packaging

✅ Proper GKI-based boot image usage

📊 Current Status
Component	Status
Device Tree	✅ Structured
Kernel (Source)	❌ Abandoned
GKI Setup	🔄 In Progress
SELinux	✅ Fixed
Modules	✅ Cleaned
Prebuilt Images	⏳ Waiting
First Boot Attempt	⏳ Pending
🧠 Lessons Learned

Modern Xiaomi devices use GKI.

Full kernel compilation is unnecessary.

DTB must come from stock.

Vendor boot + dtbo are critical.

Always confirm DTS presence before kernel integration.

🎯 Immediate Next Steps

Extract required images from stock fastboot ROM.

Place in prebuilt/.

Push with Git LFS if needed.

Run clean GKI build.

Attempt first flash
