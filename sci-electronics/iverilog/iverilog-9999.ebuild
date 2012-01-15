# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-electronics/iverilog/iverilog-0.9.3.ebuild,v 1.1 2010/11/02 01:41:19 rafaelmartins Exp $

EAPI="2"

inherit eutils autotools multilib git-2

S="${WORKDIR}/verilog"

DESCRIPTION="A Verilog simulation and synthesis tool"
#SRC_URI="ftp://icarus.com/pub/eda/verilog/v${PV:0:3}/verilog-${PV}.tar.gz"
SRC_URI=""
#EGIT_REPO_URI="git://icarus.com/~steve-icarus/verilog 
EGIT_REPO_URI="git://github.com/steveicarus/iverilog.git"
HOMEPAGE="http://www.icarus.com/eda/verilog/"

DEPEND=""
RDEPEND=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""
MAKEOPTS="${MAKEOPTS} -j1"

src_prepare() {
	# Fix tests
	mkdir -p lib/ivl
	touch lib/ivl/ivl
	sed -i -e 's/driver\/iverilog -B./IVERILOG_ROOT="." driver\/iverilog -B./' Makefile.in || die

	# Fix LDFLAGS
	sed -i -e 's/@shared@/@shared@ $(LDFLAGS)/' {cadpli,tgt-vhdl,tgt-null,tgt-stub,tgt-vvp}/Makefile.in || die "sed failed"
	eautoreconf || die "failed running autoreconf"
}

#src_compile() {
#  econf
#  emake || die "Error: emake failed!"
#}

src_install() {
	emake -j1 \
		prefix="${D}"/usr \
		mandir="${D}"/usr/share/man \
		infodir="${D}"/usr/share/info \
		libdir="${D}"/usr/$(get_libdir) \
		libdir64="${D}"/usr/$(get_libdir) \
		vpidir="${D}"/usr/$(get_libdir)/ivl \
		install || die

	dodoc *.txt
	insinto /usr/share/doc/${PF}
	doins -r examples
}
