# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils versionator

MY_P="${PN}-$(get_version_component_range 1-2)-u$(get_version_component_range 3)-b$(get_version_component_range 4)"
S="${WORKDIR}/${MY_P}"

DESCRIPTION="Unix port of Monkey's Audio"
HOMEPAGE="http://supermmx.org/linux/mac/"
SRC_URI="http://supermmx.org/resources/linux/mac/${MY_P}.tar.gz"

RESTRICT="mirror"
LICENSE="unknown"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="asmb"

DEPEND="virtual/libc
	asmb? ( dev-lang/yasm )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	patch "${S}"/src/MACLib/APELink.cpp "${FILESDIR}"/mac-3.99-u4-b5_invalid_conversation.patch
}

src_compile() {
#	patch ${S}/src/MACLib/APELink.cpp "${FILESDIR}"/mac-3.99-u4-b5_invalid_conversation.patch || die
#	epatch "${FILESDIR}"/mac-3.99-u4-b5_invalid_conversation.patch || die
	econf $(use_enable asmb assembly) || die "configure failed"
	emake || die "make failed"
}

src_install() {
	make DESTDIR=${D} install || die "make install failed"
	dodoc AUTHORS INSTALL NEWS README TODO COPYING 
	dohtml ${S}/src/License.htm	${S}/src/Readme.htm
}

