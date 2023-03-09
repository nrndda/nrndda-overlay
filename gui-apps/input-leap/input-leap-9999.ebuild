# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop virtualx xdg cmake

DESCRIPTION="Share a mouse and keyboard between computers (fork of Synergy)"
HOMEPAGE="https://github.com/input-leap/input-leap"

if [[ ${PV} == 9999 ]]; then
        EGIT_REPO_URI="https://github.com/input-leap/input-leap.git"
        inherit git-r3
	KEYWORDS=""
else
	KEYWORDS="amd64 x86"
	SRC_URI="https://github.com/input-leap/input-leap/archive/v${PV}.tar.gz -> ${P}.tar.gz"
fi

LICENSE="GPL-2"
SLOT="0"
IUSE="gui test X libei"
RESTRICT="!test? ( test )
	  || ( X libei )"

RDEPEND="
	net-misc/curl
	X? (
		x11-libs/libICE
		x11-libs/libSM
		x11-libs/libX11
		x11-libs/libXext
		x11-libs/libXi
		x11-libs/libXinerama
		x11-libs/libXrandr
		x11-libs/libXtst
	)
	libei? (
		dev-libs/libportal
		dev-libs/libei
	)
	gui? (
		dev-qt/qtcore:5
		dev-qt/qtgui:5
		dev-qt/qtnetwork:5
		dev-qt/qtwidgets:5
		net-dns/avahi[mdnsresponder-compat]
	)
	dev-libs/openssl:0=
"
DEPEND="
	${RDEPEND}
	dev-cpp/gtest
	dev-cpp/gulrak-filesystem
	X? ( x11-base/xorg-proto )
"

#PATCHES=(
#	"${FILESDIR}"/${P}-includes.patch
#)

DOCS=(
	ChangeLog
	README.md
	doc/${PN}.conf.example{,-advanced,-basic}
)

src_configure() {
	local mycmakeargs=(
		-DINPUTLEAP_BUILD_X11=$(usex X)
		-DINPUTLEAP_BUILD_LIBEI=$(usex libei)
		-DINPUTLEAP_BUILD_GUI=$(usex gui)
		-DINPUTLEAP_BUILD_INSTALLER=OFF
		-DINPUTLEAP_BUILD_TESTS=$(usex test)
		-DINPUTLEAP_REVISION=00000000
		-DINPUTLEAP_USE_EXTERNAL_GTEST=ON
		-DINPUTLEAP_VERSION_STAGE=gentoo
	)

	cmake_src_configure
}

src_test() {
	"${BUILD_DIR}"/bin/unittests || die
	virtx "${BUILD_DIR}"/bin/integtests || die
}

src_install() {
	cmake_src_install
	einstalldocs
	doman doc/${PN}{c,s}.1

	if use gui; then
		doicon -s scalable res/${PN}.svg
		doicon -s 256 res/${PN}.png
		make_desktop_entry ${PN} InputLeap ${PN} Utility
	fi
}
