# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit git-r3 autotools

DESCRIPTION="A Verilog simulation and synthesis tool"
SRC_URI=""
EGIT_REPO_URI="https://github.com/steveicarus/iverilog.git"
HOMEPAGE="http://iverilog.icarus.com/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="examples"

RDEPEND="
	app-arch/bzip2
	sys-libs/readline:0=
	sys-libs/zlib:="
DEPEND="${RDEPEND}"

S="${WORKDIR}/${P}"

src_prepare() {
	default
	eautoreconf
}

src_install() {
	emake -j1 DESTDIR="${D}" install
	einstalldocs
	dodoc *.txt

	if use examples; then
		dodoc -r examples
		docompress -x /usr/share/doc/${PF}/examples
	fi
}
