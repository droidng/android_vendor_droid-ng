PRODUCT_BRAND ?= droid-ng

PRODUCT_ENFORCE_RRO_EXCLUDED_OVERLAYS += vendor/droid-ng/overlay/iconpack
PRODUCT_PACKAGE_OVERLAYS += vendor/droid-ng/overlay/iconpack

include vendor/droid-ng/sdk/common.mk
