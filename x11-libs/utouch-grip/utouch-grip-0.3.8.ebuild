# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit base

MY_P="${P:7}"
MY_PN="${PN:7}"

DESCRIPTION="Gesture Recognition And Instantiation Library"
SRC_URI="http://launchpad.net/lib${MY_PN}/trunk/${PV}/+download/${MY_P}.tar.gz"

RESTRICT="mirror"

HOMEPAGE="https://launchpad.net/libgrip"
KEYWORDS="~x86 ~amd64"
SLOT="0"
LICENSE="GPV-3"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}
	>=x11-libs/gtk+-3.0.8:3
	>=x11-libs/utouch-geis-2.1.1
	dev-libs/gobject-introspection
	"
S="${WORKDIR}/${MY_P}"
