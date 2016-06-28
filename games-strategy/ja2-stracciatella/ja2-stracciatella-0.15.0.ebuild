# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils multilib games

DESCRIPTION="An enhanced port of Jagged Alliance 2 to SDL"
HOMEPAGE="http://ja2-stracciatella.github.io/"
SRC_URI="https://github.com/ja2-stracciatella/${PN}/archive/v${PV}.tar.gz"
LICENSE="SFI"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="sys-libs/zlib
	media-libs/libsdl"
DEPEND="${RDEPEND}"

src_configure() {
	econf
	sed -i 's/\/usr\//${D}\/usr\//' ${S}/Makefile.config
}

src_compile() {
	use amd64 && multilib_toolchain_setup x86

	emake LNG=${LNG} WITH_ZLIB=1 || die "emake"
}

pkg_postinst() {
	elog "Edit configuration file and set parameter data_dir to point on the directory where the original game files was installed."
	elog "The configuration file is: ~/.ja2/ja2.ini"
}

