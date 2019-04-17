# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6

inherit cmake-utils

DESCRIPTION="An enhanced port of Jagged Alliance 2 to SDL2"
HOMEPAGE="http://ja2-stracciatella.github.io/"
SRC_URI="https://github.com/ja2-stracciatella/${PN}/archive/v${PV}.tar.gz -> ja2-stracciatella-v${PV}.tar.gz"
LICENSE="SFI"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="launcher +system-fltk +system-boost system-rapidjson system-gtest"

RDEPEND="virtual/rust
	media-libs/libsdl2
	system-boost? ( dev-util/boost )
	launcher? (
		system-fltk? ( x11-libs/fltk )
	)
	system-rapidjson? ( dev-libs/rapidjson )
	system-gtest? ( dev-cpp/gtest )"
DEPEND="${RDEPEND}"

src_configure() {
	local mycmakeargs=(
		-DINSTALL_LIB_DIR="${EPREFIX}/usr/$(get_libdir)"
                -DWITH_UNITTESTS=OFF
	        -DWITH_FIXMES=OFF
		-DBUILD_LAUNCHER="$(usex launcher)"
		-DLOCAL_FLTK_LIB="$(usex !system-fltk)"
		-DLOCAL_BOOST_LIB="$(usex !system-boost)"
		-DLOCAL_RAPIDJSON_LIB="$(usex !system-rapidjson)"
		-DLOCAL_GTEST_LIB="$(usex !system-gtest)"
	)

	cmake-utils_src_configure
}

pkg_postinst() {
	elog "After first start edit configuration file and set parameter data_dir to point on the directory where the original game Data dir is located."
	elog "The configuration file is: ~/.ja2/ja2.ini"
}

