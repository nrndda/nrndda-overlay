# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: 

EAPI="3"
SLOT="0"
inherit eutils subversion

DESCRIPTION="CUPS drivers for Canon LBP-810 and LBP-1120"
HOMEPAGE="http://www.boichat.ch/nicolas/capt/"
KEYWORDS=""
IUSE=""
LICENSE="GPL-3"

SRC_URI=""
ESVN_REPO_URI="https://foo2capt.svn.sourceforge.net/svnroot/foo2capt"

RDEPEND="net-print/cups"

src_install() {
	emake PREFIX="/usr/" CUPSROOT="/usr/libexec/cups/" DESTDIR="${D}" install || die "emake install failed"

#	insinto /usr/share/ppd/Canon/
#	doins "${S}"/ppd/*
#
#	dobin capt
}

