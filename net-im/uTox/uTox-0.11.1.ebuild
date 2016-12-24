# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit cmake-utils

DESCRIPTION="Lightweight Tox client"
HOMEPAGE="https://github.com/uTox/uTox"
SRC_URI="https://github.com/uTox/uTox/archive/v${PV}.tar.gz -> uTox-${PV}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
IUSE="+dbus +filter_audio"
KEYWORDS="~amd64"

RDEPEND="net-libs/tox:0/0.1[av]
	media-libs/freetype
	filter_audio? ( media-libs/libfilteraudio )
	media-libs/libv4l
	media-libs/libvpx
	media-libs/openal
	x11-libs/libX11
	x11-libs/libXext
	dbus? ( sys-apps/dbus )"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_prepare() {
	#Prevent
	#CMake Error at cmake_install.cmake:36 (file):
	#  file INSTALL cannot find
	#  "/var/tmp/portage/net-im/uTox-0.11.1/work/uTox-0.11.1/utox".
	sed -i "s/^\s*utox$/\$\{CMAKE_CURRENT_BINARY_DIR\}\/utox/g" ${S}/CMakeLists.txt

	epatch_user
	cmake-utils_src_prepare
}

src_configure() {
	if use filter_audio && [ "${PROFILE_IS_HARDENED}" = 1 ]; then
		ewarn "Building µTox with support for filter_audio using hardened profile results in"
		ewarn "crash upon start. For details, see https://github.com/notsecure/uTox/issues/844"
	fi
	local mycmakeargs=( \
		DBUS=$(usex dbus "1" "0") \
		FILTER_AUDIO=$(usex filter_audio "1" "0")\
	)
	cmake-utils_src_configure
}
