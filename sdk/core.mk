# droid-ng Platform SDK Version
ADDITIONAL_SYSTEM_PROPERTIES += \
    ro.ng.build.version.plat.sdk=$(NG_PLATFORM_SDK_VERSION)

# droid-nh Platform Internal Version
ADDITIONAL_SYSTEM_PROPERTIES += \
    ro.ng.build.version.plat.rev=$(NG_PLATFORM_REV)

LINEAGE_SRC_API_DIR := $(TOPDIR)prebuilts/ng-sdk/api
INTERNAL_NG_PLATFORM_API_FILE := $(TARGET_OUT_COMMON_INTERMEDIATES)/PACKAGING/ng_public_api.txt
INTERNAL_NG_PLATFORM_REMOVED_API_FILE := $(TARGET_OUT_COMMON_INTERMEDIATES)/PACKAGING/ng_removed.txt
FRAMEWORK_NG_PLATFORM_API_FILE := $(TOPDIR)vendor/droid-ng/sdk/api/lineage_current.txt
FRAMEWORK_NG_PLATFORM_REMOVED_API_FILE := $(TOPDIR)vendor/droid-ng/sdk/api/lineage_removed.txt
FRAMEWORK_NG_API_NEEDS_UPDATE_TEXT := $(TOPDIR)vendor/droid-ng/sdk/apicheck_msg_current.txt
