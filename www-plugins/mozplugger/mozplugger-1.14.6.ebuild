# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2
inherit eutils multilib toolchain-funcs

DESCRIPTION="Configurable browser plugin to launch streaming media players."
SRC_URI="http://mozplugger.mozdev.org/files/${P}.tar.gz"
HOMEPAGE="http://mozplugger.mozdev.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~ppc ~sparc ~x86"
IUSE="+X debug gcov xembed"

DEPEND="X? ( x11-libs/libX11 )"
RDEPEND="${DEPEND}"

src_prepare() {
	epatch "${FILESDIR}/${P}-Makefile.in.patch"
	sed -i "s:libprefix=.*:libprefix=/$(get_libdir):" Makefile.in
}

src_configure() {
	local myconf
	if [[ -x ${ECONF_SOURCE:-.}/configure ]] ; then
		if use xembed; then
			myconf="${myconf} --enable-always-xembed"
		fi

		econf \
			${myconf} \
			$(use_with X x ) \
			$(use_enable debug ) \
			$(use_enable gcov )
	fi
}

src_compile() {
	emake \
		CC="$(tc-getCC)" \
		LD="$(tc-getCC)" \
		RPM_OPT_FLAGS="${CFLAGS}" \
		XCFLAGS="-fPIC -Wall" \
		COMMON_LDFLAGS="${LDFLAGS}" \
		all || die
}

src_install() {
	emake root="${D}" install || die
	dodoc ChangeLog README
}
