# droid-ng Platform Library
PRODUCT_PACKAGES += \
    org.eu.droid_ng.platform-res \
    org.eu.droid_ng.platform \
    NgSettingsProvider

# AOSP has no support of loading framework resources from /system_ext
# so the SDK has to stay in /system for now
PRODUCT_ARTIFACT_PATH_REQUIREMENT_ALLOWED_LIST += \
    system/framework/oat/%/org.eu.droid_ng.platform.odex \
    system/framework/oat/%/org.eu.droid_ng.platform.vdex \
    system/framework/org.eu.droid_ng.platform-res.apk \
    system/framework/org.eu.droid_ng.platform.jar

PRODUCT_COPY_FILES += \
    vendor/droid-ng/sdk/org.eu.droid_ng.settings.xml:system/etc/permissions/org.eu.droid_ng.settings.xml

ifndef NG_PLATFORM_SDK_VERSION
  # This is the canonical definition of the SDK version, which defines
  # the set of APIs and functionality available in the platform.  It
  # is a single integer that increases monotonically as updates to
  # the SDK are released.  It should only be incremented when the APIs for
  # the new release are frozen (so that developers don't write apps against
  # intermediate builds).
  NG_PLATFORM_SDK_VERSION := 1
endif

ifndef NG_PLATFORM_REV
  # For internal SDK revisions that are hotfixed/patched
  # Reset after each NG_PLATFORM_SDK_VERSION release
  # If you are doing a release and this is NOT 0, you are almost certainly doing it wrong
  NG_PLATFORM_REV := 0
endif
