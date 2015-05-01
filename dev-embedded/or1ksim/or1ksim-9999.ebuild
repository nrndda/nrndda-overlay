# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
inherit autotools eutils git-2

EGIT_REPO_URI="https://github.com/openrisc/or1ksim"
EGIT_BRANCH="or1k-master"

DESCRIPTION="OpenRISC SoC simulator"
HOMEPAGE="https://github.com/openrisc/or1ksim"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""

src_prepare() {
        eautoreconf
}

src_compile() {
        emake || die "emake failed"
}

src_install() {
        make DESTDIR="${D}" install || die "emake install failed"

	dodoc sim.cfg
}

