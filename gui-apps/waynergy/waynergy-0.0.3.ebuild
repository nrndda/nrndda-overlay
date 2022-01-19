# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit meson

DESCRIPTION="An implementation of a synergy client for wayland compositors."
HOMEPAGE="https://github.com/r-c-f/waynergy"
SRC_URI="https://github.com/r-c-f/waynergy/archive/refs/tags/v${PV}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND="
	dev-libs/wayland
	dev-libs/wayland-protocols
	dev-util/wayland-scanner
	x11-libs/libxkbcommon
	dev-libs/libretls
	gui-apps/wl-clipboard
"

DOCS=( LICENSE README.md )
