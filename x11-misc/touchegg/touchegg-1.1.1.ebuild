# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils qmake-utils

DESCRIPTION="Multitouch gesture recognizer"
HOMEPAGE="https://code.google.com/p/touchegg"
SRC_URI="https://github.com/JoseExposito/touchegg/archive/${PV}.tar.gz"

RESTRICT="mirror"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXtst
	dev-qt/qtcore:5
	dev-qt/qtgui:5
	x11-libs/utouch-geis"
RDEPEND="${DEPEND}"

S="${S}/${PN}"

src_prepare() {
        cd "${WORKDIR}/${P}/${PN}"
        epatch "${FILESDIR}/qt5.patch"
}

src_configure() {
        cd "${WORKDIR}/${P}/${PN}"
        eqmake5 ${PN}.pro
}

src_compile() {
  cd "${WORKDIR}/${P}/${PN}"
  emake
}

src_install() {
  cd "${WORKDIR}/${P}/${PN}"
  emake install INSTALL_ROOT="${D}"
}
