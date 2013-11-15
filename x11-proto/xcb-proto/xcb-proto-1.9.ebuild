# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-proto/xcb-proto/xcb-proto-1.9.ebuild,v 1.2 2013/11/09 09:57:32 polynomial-c Exp $

EAPI=5

PYTHON_COMPAT=( python{2_6,2_7,3_2,3_3} )
XORG_MULTILIB=yes

inherit python-r1 xorg-2

DESCRIPTION="X C-language Bindings protocol headers"
HOMEPAGE="http://xcb.freedesktop.org/"
EGIT_REPO_URI="git://anongit.freedesktop.org/git/xcb/proto"
[[ ${PV} != 9999* ]] && \
	SRC_URI="http://xcb.freedesktop.org/dist/${P}.tar.bz2"

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd ~x86-freebsd ~x86-interix ~amd64-linux ~arm-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND="${PYTHON_DEPS}"
DEPEND="${RDEPEND}
	dev-libs/libxml2"

# Work around py-compile being generated by some ancient version.
src_prepare() {
	rm -f py-compile
	epatch_user
	eautoreconf
}

src_configure() {
	python_export_best
	xorg-2_src_configure
	#Note: multilib is not supported with python, therefore use only one ABI
	python_foreach_impl autotools-utils_src_configure
}

src_compile() {
	xorg-2_src_compile

	python_foreach_impl autotools-utils_src_compile -C xcbgen \
		top_builddir="${WORKDIR}/${P}-${ABI:-${DEFAULT_ABI}}"
}

src_install() {
	xorg-2_src_install

	python_foreach_impl autotools-utils_src_install -C xcbgen \
		top_builddir="${WORKDIR}/${P}-${ABI:-${DEFAULT_ABI}}"
}
