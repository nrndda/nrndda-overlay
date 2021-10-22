# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

QTMIN=5.14.0
inherit ecm

DESCRIPTION="Onscreen keyboard using maliit framework"
HOMEPAGE="https://maliit.github.io/"
SRC_URI="https://github.com/maliit/keyboard/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/keyboard-${PV}"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~ppc64 ~x86"
IUSE="hunspell anthy pinyin chewing"

DEPEND="
	dev-libs/glib
	>=dev-qt/qtdbus-${QTMIN}:5
	>=dev-qt/qtmultimedia-${QTMIN}:5
	>=kde-misc/maliit-framework-2.1.0
	>=kde-misc/maliit-plugins-0.99.1
	hunspell? ( app-text/hunspell )
	anthy? ( app-i18n/anthy )
	pinyin? ( app-i18n/libpinyin )
	chewing? ( app-i18n/libchewing )
"
#	>=dev-qt/qtfeedback-${QTMIN}:5

RDEPEND="${DEPEND}"

src_configure() {
        local mycmakeargs=(
		-Denable-tests=OFF
		-Denable-presage=OFF
		-Denable-hunspell=$(usex hunspell)
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt5Feedback=ON
		$(cmake_use_find_package anthy Anthy)
		$(cmake_use_find_package pinyin Pinyin)
		$(cmake_use_find_package chewing Chewing)
        )
        ecm_src_configure
}
