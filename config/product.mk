PRODUCT_BRAND ?= droid-ng

PRODUCT_ENFORCE_RRO_EXCLUDED_OVERLAYS += \
    vendor/droid-ng/overlay/iconpack
PRODUCT_PACKAGE_OVERLAYS += \
    vendor/droid-ng/overlay/iconpack \
    vendor/droid-ng/overlay/common

PRODUCT_PACKAGES += \
    Jellyfish \
    FDroidPrivilegedExtension \
    additional_repos.xml

PRODUCT_COPY_FILES += \
    vendor/droid-ng/prebuilts/smartcharge.rc:$(TARGET_COPY_OUT_SYSTEM)/etc/init/smartcharge-init.rc

ifeq ($(filter arm64 arm x86 x86_64,$(TARGET_GAPPS_ARCH)),)
$(error Invalid or unset TARGET_GAPPS_ARCH "$(TARGET_GAPPS_ARCH)" - must be one of arm arm64 x86 x86_64)
endif
ifneq ($(TARGET_DISABLE_GAPPS),true)
$(call inherit-product, vendor/gapps/$(TARGET_GAPPS_ARCH)/$(TARGET_GAPPS_ARCH)-vendor.mk)
PRODUCT_PACKAGES += \
    microGmsCore \
    GsfProxy \
    FakeStore \
    microPhonesky
endif
PRODUCT_PROPERTY_OVERRIDES += \
    persist.gms_feature=0

include vendor/droid-ng/sdk/common.mk
