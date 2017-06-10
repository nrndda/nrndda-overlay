# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=4

inherit autotools eutils multilib versionator

DESCRIPTION="A Verilog simulation and synthesis tool"
MY_PV="$(get_version_component_range 1)_$(get_version_component_range 2)"
SRC_URI="https://github.com/steveicarus/iverilog/archive/v${MY_PV}.tar.gz -> ${P}.tar"
HOMEPAGE="http://iverilog.icarus.com/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~sparc ~x86"
IUSE="examples"

RDEPEND="app-arch/bzip2
	sys-libs/readline
	sys-libs/zlib"
DEPEND="${RDEPEND}"

S="${WORKDIR}/iverilog-${MY_PV}"

src_prepare() {
	# Fix tests
	mkdir -p lib/ivl
	touch lib/ivl/ivl
	sed -i -e 's/driver\/iverilog -B./IVERILOG_ROOT="." driver\/iverilog -B./' Makefile.in || die

	# Fix LDFLAGS
	sed -i -e 's/@shared@/@shared@ $(LDFLAGS)/' {cadpli,tgt-vhdl,tgt-null,tgt-stub,tgt-vvp}/Makefile.in || die

	eautoreconf
}

src_install() {
	emake -j1 \
		prefix="${ED}"/usr \
		mandir="${ED}"/usr/share/man \
		infodir="${ED}"/usr/share/info \
		libdir="${ED}"/usr/$(get_libdir) \
		libdir64="${ED}"/usr/$(get_libdir) \
		vpidir="${ED}"/usr/$(get_libdir)/ivl \
		install

	dodoc *.txt
	if use examples ; then
		insinto /usr/share/doc/${PF}
		doins -r examples
	fi
}
