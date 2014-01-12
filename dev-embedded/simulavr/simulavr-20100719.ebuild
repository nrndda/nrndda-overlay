# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
inherit autotools eutils git-2

EGIT_REPO_URI="git://git.savannah.nongnu.org/simulavr.git"
EGIT_BRANCH="master"
EGIT_COMMIT="bcd3f6259b42e2c6f36ff20946590c9e5de07cbc"

DESCRIPTION="A simulator for the Atmel AVR family of microcontrollers"
HOMEPAGE="http://www.nongnu.org/simulavr/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"

IUSE="verilog" 
# examples test verilog
RDEPEND="sys-libs/ncurses"
DEPEND="sys-apps/sed
		sys-devel/crossdev
		>=dev-lang/swig-2.0.0
		sys-apps/texinfo
		>=dev-lang/python-2.4
		verilog? ( dev-tcltk/itcl sci-electronics/iverilog )
		${RDEPEND}"

pkg_setup() {
	if ! has_version cross-avr/gcc; then
		eerror
		eerror "${PN} requires avr-gcc to be installed. You can install"
		eerror "it by running:"
		eerror "  # crossdev -t avr"
		eerror
		die "Missing avr-gcc"
	fi
}

src_prepare() {
	# Fixup expected version of SWIG:
	sed -i -e "s|AC_PROG_SWIG(1.[0-9]\+.[0-9]\+)|AC_PROG_SWIG(2.0.0)|" \
		configure.ac || die

	eautoreconf
}

src_configure() {
	local my_conf="$(use_enable verilog)"

	my_conf="${my_conf} --with-bfd=/usr/lib/binutils/avr/2.20.1/"
	econf ${my_conf} || die "econf failed"
}

src_compile() {
	emake
	#emake || die "emake failed"
}

src_install() {
	make DESTDIR="${D}" install || die "emake install failed"

	dodoc AUTHORS ChangeLog README SUPPORT TODO
}

