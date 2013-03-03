# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-cpp/yaml-cpp/yaml-cpp-0.2.7.ebuild,v 1.2 2011/09/16 10:55:24 scarabeus Exp $

EAPI=4

inherit cmake-utils git-2

DESCRIPTION="Library to access docks from Qt software, supports unity, kde 4.8, macos and windows"
HOMEPAGE="https://github.com/gorthauer/QtDockTile"
EGIT_REPO_URI="git://github.com/gorthauer/QtDockTile.git"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug"

DEPEND="dev-qt/qtgui:4"
RDEPEND="${DEPEND}"

src_unpack() {
	git-2_src_unpack
	cd "${S}"
	git submodule update --init || die "Can't update submodule"
}