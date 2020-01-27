# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit cmake-utils git-r3

DESCRIPTION="Telegram connection manager for Telepathy."
HOMEPAGE="https://github.com/TelepathyQt/telepathy-morse"
EGIT_REPO_URI=( "https://github.com/TelepathyQt/telepathy-morse.git" )

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS=""
IUSE="qt4 qt5"

REQUIRED_USE="^^ ( qt4 qt5 )"

RDEPEND="
	net-libs/telegram-qt
	>=net-libs/telepathy-qt-0.9.7
"
DEPEND="${RDEPEND}
	>=dev-util/cmake-2.8.12
"

DOCS=( README.md )

src_configure() {
	local mycmakeargs=(
			-DENABLE_TESTS=OFF
			-DENABLE_TESTAPP=OFF
			-DENABLE_EXAMPLES=OFF
	)
	if use qt4 ; then
		mycmakeargs+=( -DUSE_QT4=true )
	fi
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
}

src_install() {
	cmake-utils_src_install
}
