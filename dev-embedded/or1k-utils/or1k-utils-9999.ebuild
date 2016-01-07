# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
#WANT_AUTOCONF="2.1"

inherit autotools eutils git-2 toolchain-binutils

EGIT_REPO_URI="https://github.com/openrisc/or1k-src"
EGIT_BRANCH="or1k"

DESCRIPTION="OpenRISC SoC simulator"
HOMEPAGE="https://github.com/openrisc/or1k-src"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""

DEPEND="<=sys-devel/autoconf-2.64"
RDEPEND="${DEPEND}"

src_configure() {
	econf \
		--target=or1k-elf \
                --disable-werror \
		--enable-shared
}

src_compile() {
        emake || die "emake failed"
}

src_install() {
        make DESTDIR="${D}" install || die "emake install failed"

	#dodoc sim.cfg
}

