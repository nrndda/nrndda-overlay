# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6

inherit cmake-utils

DESCRIPTION="An enhanced port of Jagged Alliance 2 to SDL"
HOMEPAGE="http://ja2-stracciatella.github.io/"
SRC_URI="https://github.com/ja2-stracciatella/${PN}/archive/v${PV}.tar.gz"
LICENSE="SFI"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="launcher system-fltk +system-boost system-rapidjson system-gtest"

RDEPEND="dev-util/boost-build
	virtual/rust
	sys-libs/zlib
	media-libs/libsdl2"
DEPEND="${RDEPEND}"

src_configure() {
	local mycmakeargs=(
                -DWITH_UNITTESTS=OFF
	        -DWITH_FIXMES=OFF
		-DBUILD_LAUNCHER="$(usex launcher)"
		-DLOCAL_FLTK_LIB="$(usex system-fltk NO YES)"
		-DLOCAL_BOOST_LIB="$(usex system-boost NO YES)"
		-DLOCAL_RAPIDJSON_LIB="$(usex system-rapidjson NO YES)"
		-DLOCAL_GTEST_LIB="$(usex system-gtest NO YES)"
	)

	cmake-utils_src_configure
}

pkg_postinst() {
	elog "Edit configuration file and set parameter data_dir to point on the directory where the original game files was installed."
	elog "The configuration file is: ~/.ja2/ja2.ini"
}

