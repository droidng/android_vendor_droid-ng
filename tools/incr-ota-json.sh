#!/bin/bash
function get_val {
	awk -F= -v value="$1" '!/#/ && $1 == value {OFS="=";$1="";print substr($0,2)}' "$2"
}
SYSTEM_BUILD_PROP="$OUT/system/build.prop"
OTA_METADATA="$OUT/ota_metadata"
function getprop {
	get_val "$1" "$SYSTEM_BUILD_PROP"
}
function getmeta {
	get_val "$1" "$OTA_METADATA"
}

ZIPFULL="droid-ng-$(getprop ro.lineage.version).zip"
ZIPPATHFULL="$OUT/$ZIP"
ZIPPATH="$1"
ZIP="$(basename $ZIPPATH)"

datetime="$(getmeta post-timestamp)"
filename="$ZIP"
id="$(cat "$ZIPPATHFULL.sha256sum" | awk '{ print $1 }').incr"
romtype="$(getprop ro.lineage.releasetype)"
size="$(stat -c%s "$ZIPPATH")"
url="https://bigota.droid-ng.eu.org/$id/$ZIP"
version="$(getprop ro.lineage.build.version)"

function print_field_str {
	echo -n "    \"$1\": \"$(eval echo "\$$1")\""
}
function print_field_int {
	echo -n "    \"$1\": $(eval echo "\$$1")"
}
echo {
print_field_int datetime; echo ,
print_field_str filename; echo ,
print_field_str id; echo ,
print_field_str romtype; echo ,
print_field_str size; echo ,
print_field_str url; echo ,
print_field_str version; echo
echo }
