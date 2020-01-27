# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils autotools

DESCRIPTION="tox-prpl - Tox Pidgin Protocol Plugin"
HOMEPAGE="https://tox.dhs.org/"
SRC_URI="https://github.com/jin-eld/${PN}/archive/v${PV}.tar.gz -> tox-prpl-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND="dev-libs/glib
	 sys-libs/ncurses
	 net-im/pidgin
	 dev-libs/libsodium
         net-libs/tox"
DEPEND="${RDEPEND}"
DOCS=( AUTHORS COPYING ChangeLog NEWS README )

src_configure() {
        econf --with-gnu-ld
}

src_prepare() {
        eautoreconf
}
