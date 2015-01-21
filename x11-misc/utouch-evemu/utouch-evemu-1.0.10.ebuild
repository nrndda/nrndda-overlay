# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit base

MY_P=${P:7}
MY_PV=${PV:7}

DESCRIPTION="To record and replay data from kernel evdev devices"
HOMEPAGE="http://bitmath.org/code/evemu/"
SRC_URI="http://launchpad.net/${MY_PV}/trunk/${MY_P}/+download/${MY_P}.tar.gz"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE="X"

RDEPEND="X? ( >=x11-base/xorg-server-1.8 )"
DEPEND="${RDEPEND}"

src_install() {
        emake DESTDIR="${D}" install || die "install failed"
}

S="${WORKDIR}/${MY_P}"
