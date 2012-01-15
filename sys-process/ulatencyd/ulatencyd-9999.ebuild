# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

EGIT_REPO_URI="https://github.com/poelzi/ulatencyd.git"
inherit cmake-utils git flag-o-matic
SRC_URI=""

DESCRIPTION="Scriptable daemon which constantly optimizes the Linux kernel for best user experience."
HOMEPAGE="http://freshmeat.net/projects/ulatencyd"
#https://github.com/poelzi/ulatencyd/"
KEYWORDS=""

LICENSE="GPL-3"
SLOT="0"
IUSE="doc qt4 jit"

RDEPEND="dev-lang/lua
	dev-lua/luaposix
	doc? ( app-doc/doxygen )
	qt4? ( dev-python/PyQt4 )
	jit? ( dev-lang/luajit )"

src_install() {
	cmake-utils_src_install

	newinitd "${FILESDIR}/${PN}-initd" "${PN}"
	newconfd "${FILESDIR}/${PN}-confd" "${PN}"
}