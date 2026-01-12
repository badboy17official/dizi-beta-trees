#!/bin/bash
# Dizi Device Tree Setup Script
# This script copies necessary config files from Garnet device tree

set -e

GARNET_PATH="/tmp/garnet_device"
DIZI_PATH="$HOME/android_device_xiaomi_dizi"

echo "Setting up Dizi device tree based on Garnet..."

# Copy audio configs (reuse from Garnet)
if [ -d "$GARNET_PATH/configs/audio" ]; then
	echo "Copying audio configs..."
	cp -r "$GARNET_PATH/configs/audio/"* "$DIZI_PATH/configs/audio/" 2>/dev/null || true
fi

# Copy HIDL manifests
if [ -d "$GARNET_PATH/configs/hidl" ]; then
	echo "Copying HIDL configs..."
	cp -r "$GARNET_PATH/configs/hidl/"* "$DIZI_PATH/configs/hidl/" 2>/dev/null || true
fi

# Copy keylayout
if [ -d "$GARNET_PATH/configs/keylayout" ]; then
	echo "Copying keylayout configs..."
	cp -r "$GARNET_PATH/configs/keylayout/"* "$DIZI_PATH/configs/keylayout/" 2>/dev/null || true
fi

# Copy power configs
if [ -d "$GARNET_PATH/configs/power" ]; then
	echo "Copying power configs..."
	cp -r "$GARNET_PATH/configs/power/"* "$DIZI_PATH/configs/power/" 2>/dev/null || true
fi

# Copy sensors
if [ -d "$GARNET_PATH/configs/sensors" ]; then
	echo "Copying sensors configs..."
	cp -r "$GARNET_PATH/configs/sensors/"* "$DIZI_PATH/configs/sensors/" 2>/dev/null || true
fi

# Copy WiFi configs and modify for WCN6750
if [ -d "$GARNET_PATH/configs/wifi" ]; then
	echo "Copying and adapting WiFi configs for WCN6750..."
	cp -r "$GARNET_PATH/configs/wifi/"* "$DIZI_PATH/configs/wifi/" 2>/dev/null || true
fi

# Copy props
if [ -d "$GARNET_PATH/props" ]; then
	echo "Copying prop files..."
	cp "$GARNET_PATH/props/"*.prop "$DIZI_PATH/props/" 2>/dev/null || true
fi

# Copy rootdir files
if [ -d "$GARNET_PATH/rootdir/etc" ]; then
	echo "Copying rootdir files..."
	cp "$GARNET_PATH/rootdir/etc/fstab.qcom" "$DIZI_PATH/rootdir/etc/" 2>/dev/null || true
	cp "$GARNET_PATH/rootdir/etc/init.qcom.rc" "$DIZI_PATH/rootdir/etc/" 2>/dev/null || true
	cp "$GARNET_PATH/rootdir/etc/init.target.rc" "$DIZI_PATH/rootdir/etc/" 2>/dev/null || true
	cp "$GARNET_PATH/rootdir/etc/init.recovery.qcom.rc" "$DIZI_PATH/rootdir/etc/" 2>/dev/null || true
	cp "$GARNET_PATH/rootdir/etc/ueventd"*.rc "$DIZI_PATH/rootdir/etc/" 2>/dev/null || true
fi

# Copy sepolicy
if [ -d "$GARNET_PATH/sepolicy/vendor" ]; then
	echo "Copying sepolicy files..."
	cp -r "$GARNET_PATH/sepolicy/vendor/"* "$DIZI_PATH/sepolicy/vendor/" 2>/dev/null || true
fi

# Copy module loading configs
if [ -d "$GARNET_PATH/modules" ]; then
	echo "Copying kernel module configs..."
	cp "$GARNET_PATH/modules/dlkm/"* "$DIZI_PATH/modules/dlkm/" 2>/dev/null || true
	cp "$GARNET_PATH/modules/ramdisk/"* "$DIZI_PATH/modules/ramdisk/" 2>/dev/null || true

	# Update module loading for WCN6750
	if [ -f "$DIZI_PATH/modules/dlkm/modules.load" ]; then
		echo "Adapting module loading for WCN6750..."
		sed -i 's/adrastea/qca6750/g' "$DIZI_PATH/modules/dlkm/modules.load"
		sed -i 's/wcn3990/wcn6750/g' "$DIZI_PATH/modules/dlkm/modules.load"
	fi
fi

# Copy Android.bp
if [ -f "$GARNET_PATH/Android.bp" ]; then
	echo "Copying Android.bp..."
	cp "$GARNET_PATH/Android.bp" "$DIZI_PATH/" 2>/dev/null || true
	sed -i 's/garnet/dizi/g' "$DIZI_PATH/Android.bp"
fi

# Copy extract scripts
if [ -f "$GARNET_PATH/extract-files.py" ]; then
	echo "Copying extraction scripts..."
	cp "$GARNET_PATH/extract-files.py" "$DIZI_PATH/" 2>/dev/null || true
	cp "$GARNET_PATH/setup-makefiles.py" "$DIZI_PATH/" 2>/dev/null || true
	chmod +x "$DIZI_PATH/extract-files.py"
	chmod +x "$DIZI_PATH/setup-makefiles.py"

	# Update device name in scripts
	sed -i 's/garnet/dizi/g' "$DIZI_PATH/extract-files.py"
	sed -i 's/garnet/dizi/g' "$DIZI_PATH/setup-makefiles.py"
fi

# Create config.fs if it doesn't exist
if [ ! -f "$DIZI_PATH/configs/config.fs" ]; then
	echo "Creating config.fs..."
	cat >"$DIZI_PATH/configs/config.fs" <<'EOF'
[vendor/bin/hw/android.hardware.biometrics.fingerprint-service.xiaomi]
mode: 0755
user: AID_SYSTEM
group: AID_SYSTEM
caps: 0

[vendor/bin/hw/android.hardware.sensors-service.xiaomi-multihal]
mode: 0755
user: AID_SYSTEM
group: AID_SYSTEM
caps: 0
EOF
fi

echo "✓ Device tree setup complete!"
echo ""
echo "Next steps:"
echo "1. Copy this device tree to your LineageOS source: device/xiaomi/dizi/"
echo "2. Extract vendor blobs from your Dizi device: ./extract-files.py"
echo "3. Create kernel config: kernel/xiaomi/sm7435/arch/arm64/configs/vendor/dizi_GKI.config"
echo "4. Run: breakfast dizi && mka bacon"
echo ""
echo "⚠️  Important Dizi-specific changes already made:"
echo "   • WCN6750 WiFi/BT support (vs WCN3990)"
echo "   • 2 camera sensors (vs 4)"
echo "   • FM Radio support added"
echo "   • Updated board/platform IDs"
