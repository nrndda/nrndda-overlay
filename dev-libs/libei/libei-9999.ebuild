# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson

DESCRIPTION="libei is a library for Emulated Input, primarily aimed at the Wayland stack"
HOMEPAGE="https://gitlab.freedesktop.org/libinput/libei"

if [[ ${PV} == 9999 ]]; then
        EGIT_REPO_URI="https://gitlab.freedesktop.org/libinput/libei"
        inherit git-r3
else
	SRC_URI="https://gitlab.freedesktop.org/libinput/libei/-/archive/${PV}/${P}.tar.gz"
fi

LICENSE="MIT"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND="
	dev-libs/libevdev
	sys-apps/systemd
	x11-libs/libxkbcommon
	dev-python/attrs
"

DOCS=( README.md )

src_configure() {
	local emesonargs=(
		-Dtests=false
	)
	meson_src_configure
}
