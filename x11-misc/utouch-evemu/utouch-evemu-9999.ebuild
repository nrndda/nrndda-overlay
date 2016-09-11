# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils base bzr autotools

MY_P=${P:7}
MY_PN=${PN:7}

DESCRIPTION="To record and replay data from kernel evdev devices"
SRC_URI=""
EBZR_REPO_URI="https://code.launchpad.net/~oif-team/${MY_PN}/trunk"

HOMEPAGE="https://launchpad.net/evemu"

RESTRICT="mirror"

LICENSE="GPL-3"
KEYWORDS=""
SLOT="0"
IUSE="X"

RDEPEND="X? ( >=x11-base/xorg-server-1.8 )"
DEPEND="${RDEPEND}"

#S="${WORKDIR}/${MY_P}"

src_prepare() {
        cd ${S}
        eautoreconf || die "failed running autoreconf"
}
