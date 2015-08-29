# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils qt4-r2 git-2

DESCRIPTION="Multitouch gesture recognizer"
HOMEPAGE="https://code.google.com/p/touchegg"
SRC_URI=""
EGIT_REPO_URI="https://github.com/JoseExposito/touchegg.git"

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

S="${S}/${PN}"

src_configure() {
	cd "${WORKDIR}/${P}/${PN}"
	eqmake4 ${PN}.pro
}

src_compile() {
  cd "${WORKDIR}/${P}/${PN}"
  emake
}

src_install() {
  cd "${WORKDIR}/${P}/${PN}"
  emake install INSTALL_ROOT="${D}"
}
