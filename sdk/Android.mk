#
# Copyright (C) 2015 The CyanogenMod Project
#               2017-2022 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

# We have a special case here where we build the library's resources
# independently from its code, so we need to find where the resource
# class source got placed in the course of building the resources.
# Thus, the magic here.
# Also, this module cannot depend directly on the R.java file; if it
# did, the PRIVATE_* vars for R.java wouldn't be guaranteed to be correct.
# Instead, it depends on the R.stamp file, which lists the corresponding
# R.java file as a prerequisite.
ng_platform_res := APPS/org.eu.droid_ng.platform-res_intermediates/aapt

# List of packages used in ng-api-stubs
ng_stub_packages := org.eu.droid_ng.preference

ng_framework_module := $(LOCAL_INSTALLED_MODULE)

# Make sure that R.java and Manifest.java are built before we build
# the source for this library.
ng_framework_res_R_stamp := \
    $(call intermediates-dir-for,APPS,org.eu.droid_ng.platform-res,,COMMON)/src/R.stamp
LOCAL_ADDITIONAL_DEPENDENCIES := $(ng_framework_res_R_stamp)

$(ng_framework_module): | $(dir $(ng_framework_module))org.eu.droid_ng.platform-res.apk

ng_framework_built := $(call java-lib-deps, org.eu.droid_ng.platform)

# the sdk as an aar for publish, not built as part of full target
# DO NOT LINK AGAINST THIS IN BUILD
# ============================================================
include $(CLEAR_VARS)

LOCAL_MODULE := org.eu.droid_ng.platform.sdk.aar

LOCAL_JACK_ENABLED := disabled

LOCAL_CONSUMER_PROGUARD_FILE := $(LOCAL_PATH)/sdk/proguard.txt

LOCAL_RESOURCE_DIR := $(addprefix $(LOCAL_PATH)/, sdk/res/res)
LOCAL_MANIFEST_FILE := sdk/AndroidManifest.xml

ng_sdk_exclude_files := 'ng/library'
LOCAL_JAR_EXCLUDE_PACKAGES := $(ng_sdk_exclude_files)
LOCAL_JAR_EXCLUDE_FILES := none

LOCAL_STATIC_JAVA_LIBRARIES := org.eu.droid_ng.platform.sdk

include $(BUILD_STATIC_JAVA_LIBRARY)
$(LOCAL_MODULE) : $(built_aar)

# ===========================================================
# Common Droiddoc vars
ng_platform_docs_src_files := \
    $(call all-java-files-under, $(ng_sdk_src)) \
    $(call all-html-files-under, $(ng_sdk_src))

ng_platform_docs_java_libraries := \
    org.eu.droid_ng.platform.sdk

# SDK version as defined
ng_platform_docs_SDK_VERSION := 1.0

# release version
ng_platform_docs_SDK_REL_ID := 1

ng_platform_docs_LOCAL_MODULE_CLASS := JAVA_LIBRARIES

ng_platform_docs_LOCAL_DROIDDOC_SOURCE_PATH := \
    $(ng_platform_docs_src_files)

ng_platform_docs_LOCAL_ADDITIONAL_JAVA_DIR := \
    $(call intermediates-dir-for,JAVA_LIBRARIES,org.eu.droid_ng.platform.sdk,,COMMON)

# ====  the api stubs and current.xml ===========================
include $(CLEAR_VARS)

LOCAL_SRC_FILES:= \
    $(ng_platform_docs_src_files)
LOCAL_INTERMEDIATE_SOURCES:= $(ng_platform_LOCAL_INTERMEDIATE_SOURCES)
LOCAL_JAVA_LIBRARIES:= $(ng_platform_docs_java_libraries)
LOCAL_MODULE_CLASS:= $(ng_platform_docs_LOCAL_MODULE_CLASS)
LOCAL_DROIDDOC_SOURCE_PATH:= $(ng_platform_docs_LOCAL_DROIDDOC_SOURCE_PATH)
LOCAL_ADDITIONAL_JAVA_DIR:= $(ng_platform_docs_LOCAL_ADDITIONAL_JAVA_DIR)
LOCAL_ADDITIONAL_DEPENDENCIES:= $(ng_platform_docs_LOCAL_ADDITIONAL_DEPENDENCIES)

LOCAL_MODULE := ng-api-stubs

LOCAL_DROIDDOC_CUSTOM_TEMPLATE_DIR:= external/doclava/res/assets/templates-sdk

LOCAL_DROIDDOC_STUB_OUT_DIR := $(TARGET_OUT_COMMON_INTERMEDIATES)/JAVA_LIBRARIES/ng-sdk_stubs_current_intermediates/src

LOCAL_DROIDDOC_OPTIONS:= \
        -referenceonly \
        -stubpackages $(ng_stub_packages) \
        -exclude org.eu.droid_ng.platform.internal \
        -api $(INTERNAL_NG_PLATFORM_API_FILE) \
        -removedApi $(INTERNAL_NG_PLATFORM_REMOVED_API_FILE) \
        -nodocs

LOCAL_UNINSTALLABLE_MODULE := true

#include $(BUILD_DROIDDOC)

# $(gen), i.e. framework.aidl, is also needed while building against the current stub.
$(full_target): $(ng_framework_built) $(gen)
$(INTERNAL_NG_PLATFORM_API_FILE): $(full_target)
$(call dist-for-goals,sdk,$(INTERNAL_NG_PLATFORM_API_FILE))


# Documentation
# ===========================================================
include $(CLEAR_VARS)

LOCAL_MODULE := org.eu.droid_ng.platform.sdk
LOCAL_INTERMEDIATE_SOURCES:= $(ng_platform_LOCAL_INTERMEDIATE_SOURCES)
LOCAL_MODULE_CLASS := JAVA_LIBRARIES
LOCAL_MODULE_TAGS := optional

LOCAL_SRC_FILES := $(ng_platform_docs_src_files)
LOCAL_ADDITONAL_JAVA_DIR := $(ng_platform_docs_LOCAL_ADDITIONAL_JAVA_DIR)

LOCAL_IS_HOST_MODULE := false
LOCAL_DROIDDOC_CUSTOM_TEMPLATE_DIR := vendor/lineage/build/tools/droiddoc/templates-lineage-sdk
LOCAL_ADDITIONAL_DEPENDENCIES := \
    services

LOCAL_JAVA_LIBRARIES := $(ng_platform_docs_java_libraries)

LOCAL_DROIDDOC_OPTIONS := \
        -android \
        -offlinemode \
        -exclude org.eu.droid_ng.platform.internal \
        -hidePackage org.eu.droid_ng.platform.internal \
        -hdf android.whichdoc offline \
        -hdf sdk.version $(ng_platform_docs_docs_SDK_VERSION) \
        -hdf sdk.rel.id $(ng_platform_docs_docs_SDK_REL_ID) \
        -hdf sdk.preview 0 \
        -since $(NG_SRC_API_DIR)/1.txt 1

$(full_target): $(ng_framework_built) $(gen)
#include $(BUILD_DROIDDOC)

include $(call first-makefiles-under,$(LOCAL_PATH))

# Cleanup temp vars
# ===========================================================
ng_platform_docs_src_files :=
bg_platform_docs_java_libraries :=
ng_platform_docs_LOCAL_ADDITIONAL_JAVA_DIR :=
