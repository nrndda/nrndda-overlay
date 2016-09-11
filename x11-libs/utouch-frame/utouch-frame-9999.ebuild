# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit eutils autotools bzr

MY_P="${P:7}"
MY_PN="${PN:7}"

DESCRIPTION="Touch Frame Library "
SRC_URI=""
EBZR_REPO_URI="https://code.launchpad.net/~oif-team/${MY_PN}/trunk"

RESTRICT="mirror"

HOMEPAGE="https://launchpad.net/frame"
KEYWORDS=""
SLOT="0"
LICENSE="GPL-3"
IUSE="evemu"

RDEPEND=""
DEPEND="${RDEPEND}
	evemu? ( x11-misc/utouch-evemu )
"


src_prepare() {
        eautoreconf
}
src_configure() {
       econf \
               $(use_with evemu)
}
