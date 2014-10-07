# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit linux-info xorg-2

DESCRIPTION="Generic Linux input driver"
KEYWORDS="**"
IUSE=""

RDEPEND=">=x11-base/xorg-server-1.12[udev]
	dev-libs/libevdev
	sys-libs/mtdev"
DEPEND="${RDEPEND}
	>=x11-proto/inputproto-2.1.99.3
	>=sys-kernel/linux-headers-2.6"

EPATCH_SOURCE=${FILESDIR}
PATCHES=( lack_absx_0001.patch lack_absx_0002.patch lack_absx_0003.patch )

pkg_pretend() {
	if use kernel_linux ; then
		CONFIG_CHECK="~INPUT_EVDEV"
	fi
	check_extra_config
}
