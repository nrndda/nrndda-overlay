# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit desktop qmake-utils

DESCRIPTION="Qt6 client for the music player daemon (MPD)"
HOMEPAGE="https://sourceforge.net/projects/quimup/"
SRC_URI="mirror://sourceforge/${PN}/${PN^}-${PV}.source.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND="
	dev-qt/qtbase[gui,network,widgets]
	dev-qt/qtsvg:6
	>=media-libs/libmpdclient-2.3
	media-libs/taglib
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

S="${WORKDIR}/${PN^}"

DOCS=( changelog faq readme )

src_configure() {
	eqmake6
}

src_install() {
	default
	dobin ${PN}

	#newicon source/resources/qm_main_icon.png ${PN}.png
	make_desktop_entry ${PN} Quimup
}
