# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit cmake-utils cmake-multilib git-r3

EGIT_REPO_URI="https://github.com/ja2-stracciatella/ja2-stracciatella.git"

DESCRIPTION="An enhanced port of Jagged Alliance 2 to SDL"
HOMEPAGE="http://ja2-stracciatella.github.io/"
SRC_URI=""
LICENSE="SFI"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND="dev-util/boost-build
	sys-libs/zlib
	media-libs/libsdl"
DEPEND="${RDEPEND}"

pkg_postinst() {
	elog "Edit configuration file and set parameter data_dir to point on the directory where the original game files was installed."
	elog "The configuration file is: ~/.ja2/ja2.ini"
}

