#!/bin/bash -e

SOURCES=$(dirname "$(readlink -f "${0}")")

source ../fetch-deps.sh

ARCH=$(dpkg-architecture -qDEB_HOST_ARCH)
CLICK_TARGET_DIR="$SOURCES/build/tmp"

if [ ! -d $SOURCE/build/deps ]; then
	download_deps;
else
	echo "I: Copying deps from cache"
fi

if [ ! -d $CLICK_TARGET_DIR ]; then mkdir $CLICK_TARGET_DIR; fi
cp $SOURCES/build/deps/* $CLICK_TARGET_DIR -r

echo "I: Copying application"
cp -r \
	$SOURCES/contents \
	$SOURCES/org.kde.kirigamigallery.desktop \
	$SOURCES/apparmor.json \
	$CLICK_TARGET_DIR

sed s/@CLICK_ARCH@/$ARCH/g $SOURCES/manifest.json.in > $CLICK_TARGET_DIR/manifest.json
