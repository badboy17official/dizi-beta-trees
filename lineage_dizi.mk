#
# Copyright (C) 2024 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
TARGET_SUPPORTS_OMX_SERVICE := false
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit some common Lineage stuff.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

# Inherit from dizi device
$(call inherit-product, device/xiaomi/dizi/device.mk)

PRODUCT_NAME := lineage_dizi
PRODUCT_DEVICE := dizi
PRODUCT_MANUFACTURER := Xiaomi
PRODUCT_BRAND := Redmi
PRODUCT_MODEL := 23122RKC6C

PRODUCT_SYSTEM_NAME := dizi_eea_global
PRODUCT_SYSTEM_DEVICE := dizi

PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildDesc="dizi_eea_global-user 15 AQ3A.240912.001 OS2.0.207.0.VNSEUXM release-keys" \
    BuildFingerprint=Redmi/dizi_eea_global/dizi:15/AQ3A.240912.001/OS2.0.207.0.VNSEUXM:user/release-keys \
    DeviceName=$(PRODUCT_SYSTEM_DEVICE) \
    DeviceProduct=$(PRODUCT_SYSTEM_NAME)

PRODUCT_GMS_CLIENTID_BASE := android-xiaomi
