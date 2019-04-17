# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6

inherit cmake-utils git-r3

EGIT_REPO_URI="https://github.com/ja2-stracciatella/ja2-stracciatella.git"

DESCRIPTION="An enhanced port of Jagged Alliance 2 to SDL2"
HOMEPAGE="http://ja2-stracciatella.github.io/"
SRC_URI=""
LICENSE="SFI"
SLOT="0"
KEYWORDS=""
IUSE="launcher +system-fltk +system-boost system-rapidjson system-gtest"

RDEPEND="
	media-libs/libsdl2
	system-boost? ( dev-util/boost )
	launcher? (
		system-fltk? ( x11-libs/fltk )
	)
	system-rapidjson? ( dev-libs/rapidjson )
	system-gtest? ( dev-cpp/gtest )"
DEPEND="
	>=virtual/cargo-1.32.0
	>=virtual/rust-1.32.0
	${RDEPEND}"

src_configure() {
	local mycmakeargs=(
		-DINSTALL_LIB_DIR="${EPREFIX}/usr/$(get_libdir)"
		-DEXTRA_DATA_DIR="${EPREFIX}/usr/share/ja2/"
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

