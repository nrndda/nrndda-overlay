# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"
#WANT_AUTOCONF="2.1"

inherit git-2 toolchain

EGIT_REPO_URI="https://github.com/openrisc/or1k-gcc"
EGIT_BRANCH="or1k"

DESCRIPTION="OpenRISC SoC GCC"
HOMEPAGE="https://github.com/openrisc/or1k-gcc"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""

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
}

