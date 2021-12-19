# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

KFMIN=5.80.0
QTMIN=5.15.0
inherit cmake git-r3

DESCRIPTION="KDE Plasma control module for maliit"
HOMEPAGE="https://invent.kde.org/nicolasfella/maliit-kcm"
EGIT_REPO_URI="https://invent.kde.org/nicolasfella/maliit-kcm"
SRC_URI=""

LICENSE="LGPL-2.1"
SLOT="5"
KEYWORDS=""
IUSE=""

DEPEND="
	>=dev-qt/qtcore-${QTMIN}:5
	>=dev-qt/qtquickcontrols-${QTMIN}:5
	>=kde-frameworks/kcoreaddons-${KFMIN}:5
	>=kde-frameworks/ki18n-${KFMIN}:5
	>=kde-frameworks/kdeclarative-${KFMIN}:5
"
