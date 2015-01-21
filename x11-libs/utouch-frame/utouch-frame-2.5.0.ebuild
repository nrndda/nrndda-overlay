# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit base

MY_P="${P:7}"
MY_PN="${PN:7}"

DESCRIPTION="Touch Frame Library "
SRC_URI="https://launchpad.net/${MY_PN}/trunk/v${PV}/+download/${MY_P}.tar.gz"

RESTRICT="mirror"

HOMEPAGE="https://launchpad.net/frame"
KEYWORDS="~x86 ~amd64"
SLOT="0"
LICENSE="GPL-3"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}
    x11-misc/utouch-evemu"

S="${WORKDIR}/${MY_P}"
