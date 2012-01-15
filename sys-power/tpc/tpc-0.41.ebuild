# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/emacs/emacs-23.2-r2.ebuild,v 1.12 2010/12/29 13:09:01 ulm Exp $

EAPI=2

inherit autotools eutils 

SRC_URI="http://amdath800.dyndns.org/amd/tpc/${P}.tar.gz"

DESCRIPTION="Turion Power Control"
HOMEPAGE="http://bazaar.launchpad.net/~klich-lukasz/tpc http://amdath800.dyndns.org/amd/"

LICENSE="GPL-3 as-is unicode"
KEYWORDS="amd64 x86"
IUSE=""
SLOT="0"
S="${WORKDIR}"
#RDEPEND="x11-libs/qwt:5"

#DEPEND="${RDEPEND}"
#PATCHES="tpc-qwt5.patch"

#src_prepare() {
#	cd "${S}"/src
#	epatch "${FILESDIR}"/tpc-makefile.patch || die "epatch failed"
#}

src_compile() {
	cd "${S}"/src/
	emake || die "emake failed"
}

src_install () {
	exeinto /usr/local/sbin/
	doexe "${S}"/src/TurionPowerControl
	
	insinto /usr/local/share/doc/
	newins "${S}"/doc/readme.pdf TurionPowerControl.pdf
	
	insinto /usr/local/sbin/
	#newins "${S}"/bin/Fedora13-x86_64/example.cfg TurionPowerControl.cfg
	newins "${S}"/bin/Ubuntu-x86_64/example.cfg TurionPowerControl.cfg
}
