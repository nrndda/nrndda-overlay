# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils multilib games git-r3

EGIT_REPO_URI="https://bitbucket.org/gennady/ja2-stracciatella.git"

DESCRIPTION="An enhanced port of Jagged Alliance 2 to SDL"
HOMEPAGE="https://bitbucket.org/gennady/ja2-stracciatella/overview"
SRC_URI=""
LICENSE="SFI"
SLOT="0"
KEYWORDS=""
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

