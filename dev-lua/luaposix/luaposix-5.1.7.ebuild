# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: Exp $

EAPI=2

inherit eutils

DESCRIPTION="POSIX bindings for LUA."
HOMEPAGE="http://git.alpinelinux.org/cgit/luaposix"
SRC_URI="http://luaforge.net/frs/download.php/4631/${P}.tar.bz2"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=dev-lang/lua-5.1"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

src_install() {
	make DESTDIR="${D}" install || die "Install failed"
	dodoc README || die
}
