# LineageOS Device Tree for Xiaomi Dizi (Based on Garnet)

## Device Information

**Device Name:** Xiaomi Dizi (POCO Pad variant)
**Model:** 2405CPCFBG
**Codename:** dizi
**SoC:** Qualcomm SM7435P (Parrot)
**SoC ID:** 638
**Release:** 2024

## Key Hardware Differences from Garnet

### 1. Wireless Connectivity
- **Garnet:** WCN3990 (Adrastea) - Older generation
- **Dizi:** WCN6750 (QCA6750) - Newer generation with better performance
  - Firmware path: `qca6750/wpss.mdt` vs `adrastea/wpss.mdt`
  - More power rails (8 vs 4 for Bluetooth)
  - Enhanced thermal management
  - WiFi config path: `/vendor/etc/wifi/qca6750/` vs `/vendor/etc/wifi/adrastea/`

### 2. Camera Configuration
- **Garnet:** 4 camera sensors (quad-camera setup)
  - cam-sensor0, 1, 2, 3
  - 4 MCLK lines
  - 4 EEPROMs
- **Dizi:** 2 camera sensors (dual-camera setup)
  - Main: aac_gc08a3 (wide/main camera)
  - Front: aac_ov08d10 (front camera)
  - 2 MCLK lines
  - 2 EEPROMs
  
### 3. FM Radio
- **Garnet:** No FM radio support
- **Dizi:** Full FM radio support (rtc6226 chipset)
  - Binaries: fm_qsoc_patches, fmconfig, fmfactorytest
  - Android permission: android.hardware.radio.fm.xml

### 4. Battery Authentication
- **Garnet:** Standard battery management
- **Dizi:** Battery authentication support (`lc,auth-battery`)

### 5. Additional Features in Dizi
- Hall sensor for lid detection (xiaomi_hall/lid_hall)
- SIM tray detection
- Multiple audio amplifier configurations

### 6. Platform Identifiers
- **Board ID:** `0x2000b 0x01` (Dizi) vs `0x1000b 0x00` (Garnet)
- **MSM ID:** Supports more SoC variants (7 vs 3)
- **PMIC ID:** Different PMIC configuration
- No xiaomi,miboard-id on Dizi (removed Xiaomi-specific identifier)

## Device Tree Structure

```
device/xiaomi/dizi/
├── Android.bp
├── AndroidProducts.mk
├── BoardConfig.mk
├── board-info.txt
├── device.mk
├── lineage_dizi.mk
├── lineage.dependencies
├── configs/
│   ├── audio/
│   ├── hidl/
│   ├── keylayout/
│   ├── power/
│   ├── sensors/
│   └── wifi/
├── modules/
│   ├── dlkm/
│   │   ├── modules.blocklist
│   │   └── modules.load
│   └── ramdisk/
│       ├── modules.blocklist
│       ├── modules.load
│       └── modules.load.recovery
├── overlay/
├── props/
│   ├── odm.prop
│   ├── system.prop
│   ├── system_ext.prop
│   └── vendor.prop
├── rootdir/
│   └── etc/
│       ├── fstab.qcom
│       └── init.dizi.rc
└── sepolicy/
    └── vendor/
```

## Key Changes from Garnet Device Tree

### 1. BoardConfig.mk
- **Line 96:** Changed `TARGET_KERNEL_ADDITIONAL_FLAGS := TARGET_PRODUCT=dizi`
- **Line 99:** Added `vendor/dizi_GKI.config` to kernel config
- **Line 139:** Changed kernel module from `.adrastea` to `.qca6750` for WCN6750 support

### 2. device.mk
- **Lines 122-128:** Updated camera permissions (removed extra sensor configs)
- **Lines 155-161:** **NEW** Added FM Radio support packages and permissions
- **Line 195:** Changed init script to `init.dizi.rc`
- **Line 313:** Changed properties package to `dizi_sku_properties`
- **Lines 282-291:** Updated overlay packages for Dizi
- **Lines 448-450:** Changed WiFi config path from `adrastea/` to `qca6750/`

### 3. lineage_dizi.mk
- **Line 18-22:** Updated product identifiers:
  - PRODUCT_NAME: lineage_dizi
  - PRODUCT_DEVICE: dizi
  - PRODUCT_MODEL: 2405CPCFBG
- **Line 24-25:** System name: dizi_p_eea
- **Line 28-29:** Updated build fingerprint to match Dizi stock ROM

### 4. Kernel Configuration
Create `vendor/dizi_GKI.config` in kernel tree with:
```
# Dizi specific kernel configs
CONFIG_QCA_CLD_WLAN=m
CONFIG_QCA6750=y
CONFIG_CNSS_QCA6750=y
CONFIG_WCNSS_MEM_PRE_ALLOC=y

# FM Radio
CONFIG_RADIO_IRIS=y
CONFIG_RADIO_IRIS_TRANSPORT=m

# Camera sensors
CONFIG_MSMB_CAMERA=y
CONFIG_GC08A3=y
CONFIG_OV08D10=y

# Battery authentication
CONFIG_AUTH_BATTERY=y
```

## Build Instructions

### 1. Initialize LineageOS Build Environment
```bash
repo init -u https://github.com/LineageOS/android.git -b lineage-23.0 --git-lfs
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
```

### 2. Clone Device Tree
```bash
git clone https://github.com/YOUR_USERNAME/android_device_xiaomi_dizi device/xiaomi/dizi
```

### 3. Clone Vendor Blobs
You need to extract vendor blobs from your Dizi device:
```bash
cd device/xiaomi/dizi
./extract-files.py
```

Or create the vendor tree manually:
```bash
git clone https://github.com/YOUR_USERNAME/proprietary_vendor_xiaomi vendor/xiaomi/dizi
```

### 4. Sync Dependencies
```bash
cd ~/android/lineage
. build/envsetup.sh
breakfast dizi
```

### 5. Build ROM
```bash
croot
mka bacon
```

## Extracting Vendor Blobs

### From Connected Device (Recommended)
```bash
cd device/xiaomi/dizi
adb root
./extract-files.py
```

### From Stock ROM
1. Download and extract Dizi stock ROM (OS2.0.207.0.VNSEUXM or later)
2. Extract system, vendor, product partitions
3. Run extraction script:
```bash
./extract-files.py /path/to/extracted/rom
```

## Critical Proprietary Files for Dizi

### WCN6750 WiFi/BT Firmware
```
vendor/firmware/qca6750/wpss.mdt
vendor/firmware/qca6750/wlanmdsp.mbn
vendor/etc/wifi/qca6750/WCNSS_qcom_cfg.ini
vendor/lib64/libwifi-hal-qcom.so
```

### FM Radio
```
vendor/bin/fm_qsoc_patches
vendor/bin/fmconfig
vendor/bin/fmfactorytest
vendor/lib64/libfm-hci.so
vendor/lib64/libfmpal.so
```

### Camera (2 sensors)
```
vendor/lib64/camera/com.qti.sensor.aac_gc08a3.so
vendor/lib64/camera/com.qti.sensor.aac_ov08d10.so
vendor/lib64/camera/components/com.qti.node.eisv2.so
vendor/lib64/camera/components/com.qti.node.eisv3.so
```

### Battery Authentication
```
vendor/lib64/hw/vendor.xiaomi.hw.batteryauth@1.0-impl.so
vendor/etc/init/vendor.xiaomi.hw.batteryauth@1.0-service.rc
```

## Device Tree Overlay (DTO)

The DTB files in this repository were extracted from the stock ROM:
- `01_dtbdump_Qualcomm_Technologies,_Inc._Parrot_QRD,_DIZI_based_on_SM7435P.dts`

Key DTO modifications needed:
1. WCN6750 configuration vs WCN3990
2. Remove camera sensors 2 and 3 definitions
3. Add FM radio (rtc6226) device node
4. Add battery authentication device
5. Update board and platform IDs

## Testing Checklist

After building, test the following:

### Essential
- [ ] Boot to system
- [ ] WiFi connects (WCN6750)
- [ ] Bluetooth pairs and connects
- [ ] Mobile data/Calls/SMS
- [ ] Camera (both front and rear)
- [ ] Audio playback and recording
- [ ] Touchscreen responsiveness

### Dizi-Specific
- [ ] FM Radio tuning and playback
- [ ] Hall sensor (lid detection)
- [ ] SIM tray detection
- [ ] Battery authentication
- [ ] WCN6750 advanced features (WiFi 6, 5GHz)

### Performance
- [ ] WiFi speed test (should be faster than WCN3990)
- [ ] Camera quality (compare with stock)
- [ ] Battery life monitoring

## Known Issues & Workarounds

### 1. WiFi Firmware Loading
If WiFi doesn't work, check firmware path:
```bash
adb shell ls -l /vendor/firmware/qca6750/
```
Ensure `wpss.mdt` and related files exist.

### 2. FM Radio Not Working
Check if FM service is running:
```bash
adb shell service list | grep fm
```
Verify permissions on `/dev/radio0`.

### 3. Camera HAL Crashes
If camera crashes, check logcat for sensor initialization:
```bash
adb logcat | grep -E "aac_gc08a3|aac_ov08d10"
```

## Maintainer Notes

### Updating from Garnet Changes
When Garnet device tree receives updates:

1. Review Garnet commits
2. Apply relevant changes to Dizi, considering:
   - Skip WCN3990-specific changes
   - Skip camera sensor 2/3 changes
   - Keep Dizi FM radio configs
   - Maintain WCN6750 paths

3. Test thoroughly after each major update

### Kernel Module Loading Order
WCN6750 requires specific module loading order:
```
# modules/ramdisk/modules.load
qca_cld3_qca6750.ko
bt_fm_slim.ko  # For FM radio
```

## Credits

- **Base Device Tree:** LineageOS Garnet maintainers
- **Dizi Adaptation:** [Your Name]
- **WCN6750 Support:** Qualcomm CNSS drivers
- **DTB Extraction:** dtbToolCM / Android Image Kitchen

## License

Copyright (C) 2024 The LineageOS Project

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
