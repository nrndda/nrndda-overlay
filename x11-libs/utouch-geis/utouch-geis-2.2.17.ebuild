# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

PYTHON_COMPAT=( python{2_7,3_{2,3,4}} )
inherit base python-r1

MY_P="${P:7}"
MY_PN="${PN:7}"

DESCRIPTION="An implementation of the GEIS (Gesture Engine Interface and Support) interface."
SRC_URI="https://launchpad.net/${MY_PN}/trunk/${PV}/+download/${MY_P}.tar.xz"

RESTRICT="mirror"

HOMEPAGE="https://launchpad.net/geis"
KEYWORDS="~x86 ~amd64"
SLOT="0"
LICENSE="GPL-2 LGPL-3"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}
	x11-libs/utouch-grail"

S="${WORKDIR}/${MY_P}"
