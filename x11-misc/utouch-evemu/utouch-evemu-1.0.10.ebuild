# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit base

MY_P=${P:7}
MY_PN=${PN:7}

DESCRIPTION="To record and replay data from kernel evdev devices"
HOMEPAGE="https://launchpad.net/evemu"
SRC_URI="http://launchpad.net/${MY_PN}/trunk/${MY_P}/+download/${MY_P}.tar.gz"

RESTRICT="mirror"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE="X"

RDEPEND="X? ( >=x11-base/xorg-server-1.8 )"
DEPEND="${RDEPEND}"

S="${WORKDIR}/${MY_P}"
