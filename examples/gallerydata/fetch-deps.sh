#!/bin/bash -e

ARCH=$(dpkg-architecture -qDEB_HOST_ARCH)
DEB_HOST_MULTIARCH=$(dpkg-architecture -qDEB_HOST_MULTIARCH)

DEB_TARGET_DIR="build/deps"

KIRIGAMI_VERSION="5.44.0-2"
QQC2_VERSION="5.9.3-0ubports3"

install_deb() {
	BASE_URL="${1}"; PKG="${2}"; VERSION="${3}"
	DEB_NAME="${PKG}_${VERSION}_${ARCH}.deb"

	# download deb using curl with a nice progress bar
	wget ${BASE_URL}/${DEB_NAME} -O "/tmp/${DEB_NAME}"
	# install to click
	dpkg-deb -x "/tmp/${DEB_NAME}" ${DEB_TARGET_DIR}
	# clean up
	rm "/tmp/${DEB_NAME}"
}

download_deps() {
	echo "I: Installing Kirigami 2"
	for PKG in qml-module-org-kde-kirigami2 kirigami2-dev libkf5kirigami2-5; do
		install_deb http://snapshot.debian.org/archive/debian/20180430T215634Z/pool/main/k/kirigami2 ${PKG} ${KIRIGAMI_VERSION}
	done

	echo "I: Installing QtQuick Controls 2"
	for PKG in qml-module-qtquick-controls2 libqt5quickcontrols2-5 qtquickcontrols2-5-dev qml-module-qtquick-templates2 qml-module-qt-labs-platform libqt5quicktemplates2-5 libqt5quicktemplates2-5; do
		install_deb https://repo.ubports.com/pool/xenial/main/q/qtquickcontrols2-opensource-src ${PKG} ${QQC2_VERSION}
	done


	echo "I: Installing QML modules"
	mv $DEB_TARGET_DIR/usr/lib/$DEB_HOST_MULTIARCH/qt5/qml/* $DEB_TARGET_DIR/usr/lib/$DEB_HOST_MULTIARCH
	echo "I: Installing libraries"
	mv $DEB_TARGET_DIR/usr/* $DEB_TARGET_DIR/
}

if [ ! -d build/deps ]; then download_deps; fi
