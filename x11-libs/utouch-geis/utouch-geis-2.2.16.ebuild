# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
inherit base python

MY_P="${P:7}"
MY_PN="${PN:7}"

DESCRIPTION="An implementation of the GEIS (Gesture Engine Interface and Support) interface."
SRC_URI="https://launchpad.net/${MY_PN}/trunk/${PV}/+download/${MY_P}.tar.gz"

RESTRICT="mirror"

HOMEPAGE="https://launchpad.net/geis"
KEYWORDS="~x86 ~amd64"
SLOT="0"
LICENSE="GPL-2 LGPL-3"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}
	x11-libs/utouch-grail"
PYTHON_DEPEND="2 3"

S="${WORKDIR}/${MY_P}"

src_prepare() {
	sed -i 's/python >= 2.7/python-2.7 >= 2.7/g' configure;
	sed -i 's/python3 >= 3.2/python >= 3.2/g' configure;
}
