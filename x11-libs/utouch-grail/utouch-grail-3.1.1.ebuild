# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit eutils autotools

MY_P="${P:7}"
MY_PN="${PN:7}"

DESCRIPTION="Gesture Recognition And Instantiation Library"
SRC_URI="http://launchpad.net/${MY_PN}/trunk/${PV}/+download/${MY_P}.tar.bz2"


RESTRICT="mirror"

HOMEPAGE="https://launchpad.net/grail"
KEYWORDS="~x86 ~amd64"
SLOT="0"
LICENSE="GPV-3"
IUSE="evemu"

RDEPEND=""
DEPEND="${RDEPEND}
	sys-libs/mtdev
	?evemu ( x11-misc/utouch-evemu )
	x11-libs/utouch-frame
	"
S="${WORKDIR}/${MY_P}"

src_prepare() {
        eautoreconf
}
src_configure() {
       econf \
               $(use_with evemu)
}
