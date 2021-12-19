# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

KFMIN=5.86
QTMIN=5.15.0
inherit ecm

DESCRIPTION="KDE Plasma Mobile settings"
HOMEPAGE="https://www.plasma-mobile.org/"
if [[ ${PV} == 9999 ]]; then
	EGIT_REPO_URI="https://invent.kde.org/plasma-mobile/plasma-settings"
	inherit git-r3
else
	SRC_URI="mirror://kde/stable/plasma-mobile/${PV}/${P}.tar.xz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="|| ( GPL-2 GPL-3 ) LGPL-2+ LGPL-2.1"
SLOT="5"

DEPEND="
	dev-libs/glib:2
	>=dev-qt/qtdbus-${QTMIN}:5
	>=dev-qt/qtdeclarative-${QTMIN}:5
	>=dev-qt/qtgui-${QTMIN}:5
	>=dev-qt/qtwidgets-${QTMIN}:5
	>=dev-qt/qtxml-${QTMIN}:5
	>=kde-frameworks/kauth-${KFMIN}:5
	>=kde-frameworks/kconfig-${KFMIN}:5
	>=kde-frameworks/kcoreaddons-${KFMIN}:5
	>=kde-frameworks/kdbusaddons-${KFMIN}:5
	>=kde-frameworks/kdeclarative-${KFMIN}:5
	>=kde-frameworks/ki18n-${KFMIN}:5
	>=kde-frameworks/kio-${KFMIN}:5
	>=kde-frameworks/kpackage-${KFMIN}:5
	>=kde-frameworks/kservice-${KFMIN}:5
	>=kde-frameworks/modemmanager-qt-${KFMIN}:5
	>=kde-frameworks/networkmanager-qt-${KFMIN}:5
	>=kde-frameworks/plasma-${KFMIN}:5
	>=kde-frameworks/solid-${KFMIN}:5
	virtual/libcrypt:=
"
RDEPEND="${DEPEND}"
