# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
inherit autotools eutils git-2

EGIT_REPO_URI="https://github.com/olofk/fusesoc.git"
#EGIT_BRANCH="master"
#EGIT_COMMIT="bcd3f6259b42e2c6f36ff20946590c9e5de07cbc"

DESCRIPTION="OpenRISC SoC builder"
HOMEPAGE="https://github.com/olofk/fusesoc"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""

src_prepare() {
        eautoreconf
}

src_compile() {
        emake || die "emake failed"
}

src_install() {
        make DESTDIR="${D}" install || die "emake install failed"

	dodoc ${S}/doc/sapi.txt
	dodoc ${S}/doc/capi.txt
}

