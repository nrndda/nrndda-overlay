# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

KFMIN=5.86.0
QTMIN=5.15.0
inherit cmake git-r3

DESCRIPTION="KDE Plasma Mobile control module for virtual keyboard"
HOMEPAGE="https://invent.kde.org/plasma-mobile/plasma-settings"
EGIT_REPO_URI="https://invent.kde.org/plasma-mobile/plasma-settings"
SRC_URI=""

LICENSE="LGPL-2.1"
SLOT="5"
KEYWORDS=""
IUSE=""

DEPEND="
	>=dev-qt/qtcore-${QTMIN}:5
	>=dev-qt/qtquickcontrols-${QTMIN}:5
	>=dev-qt/qtgui-${QTMIN}:5
	>=dev-qt/qtwidgets-${QTMIN}:5
	>=kde-frameworks/kcoreaddons-${KFMIN}:5
	>=kde-frameworks/kauth-${KFMIN}:5
	>=kde-frameworks/kconfig-${KFMIN}:5
	>=kde-frameworks/solid-${KFMIN}:5
	>=kde-frameworks/ki18n-${KFMIN}:5
	>=kde-frameworks/kdbusaddons-${KFMIN}:5
	>=kde-frameworks/plasma-${KFMIN}:5
	>=kde-frameworks/kservice-${KFMIN}:5
	>=kde-frameworks/kdeclarative-${KFMIN}:5
	>=kde-frameworks/kio-${KFMIN}:5
	>=kde-frameworks/modemmanager-qt-${KFMIN}:5
	>=kde-frameworks/networkmanager-qt-${KFMIN}:5
"

src_install() {
	mkdir -p "${D}"/usr/share/kpackage/kcms || die
	cp -R "${S}"/modules/virtualkeyboard/package "${D}"/usr/share/kpackage/kcms/kcm_mobile_virtualkeyboard || die

	insinto /usr/lib64/qt5/plugins/kcms/
	doins "${S}_build"/bin/kcm_mobile_virtualkeyboard.so

	insinto /usr/share/kservices5/
	newins "${S}"/modules/virtualkeyboard/package/metadata.desktop kcm_mobile_virtualkeyboard.desktop
}
