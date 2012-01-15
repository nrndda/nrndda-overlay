# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/emacs/emacs-23.2-r2.ebuild,v 1.12 2010/12/29 13:09:01 ulm Exp $

EAPI=2

inherit autotools bzr eutils 

EBZR_REPO_URI="http://bazaar.launchpad.net/~klich-lukasz/tpc/trunk/"
SRC_URI=""

DESCRIPTION="Turion Power Control"
HOMEPAGE="http://bazaar.launchpad.net/~klich-lukasz/tpc"

LICENSE="GPL-3 as-is unicode"
KEYWORDS="**"
IUSE=""
SLOT="0"

RDEPEND="x11-libs/qwt:5
	"

DEPEND="${RDEPEND}
	"
PATCHES="tpc-qwt5.patch"

src_prepare() {
	cd "${S}"
	epatch "${FILESDIR}"/tpc-qwt5.patch || die "epatch failed"
}

src_compile() {
	cd "${S}"
	qmake || die "qmake failed"
	emake || die "emake failed"
}

src_install () {

	emake install DESTDIR="${D}" || die "make install failed"
}
