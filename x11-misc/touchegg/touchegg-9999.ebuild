# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils qt4-r2 subversion

DESCRIPTION="Multitouch gesture recognizer"
HOMEPAGE="https://code.google.com/p/touchegg"
#SRC_URI="https://touchegg.googlecode.com/files/${P}.tar.gz"
ESVN_REPO_URI="http://touchegg.googlecode.com/svn/touchegg"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND="
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXtst
	dev-qt/qtcore:4
	dev-qt/qtgui:4
	x11-libs/utouch-geis"
RDEPEND="${DEPEND}"

src_configure() {
	eqmake4 "${S}"/${PN}.pro
}
