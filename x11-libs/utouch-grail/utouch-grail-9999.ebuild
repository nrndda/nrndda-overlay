# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils autotools bzr

MY_P="${P:7}"
MY_PN="${PN:7}"

DESCRIPTION="Gesture Recognition And Instantiation Library"
SRC_URI=""
EBZR_REPO_URI="https://code.launchpad.net/~oif-team/${MY_PN}/trunk"

RESTRICT="mirror"

HOMEPAGE="https://launchpad.net/grail"
KEYWORDS=""
SLOT="0"
LICENSE="GPV-3"
IUSE="evemu"

RDEPEND=""
DEPEND="${RDEPEND}
	sys-libs/mtdev
	evemu? ( x11-misc/utouch-evemu )
	x11-libs/utouch-frame
	"

src_prepare() {
        eautoreconf
}
src_configure() {
       econf \
               $(use_with evemu)
}
