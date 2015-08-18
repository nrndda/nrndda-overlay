# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit base bzr

MY_P="${P:7}"
MY_PN="${PN:7}"

DESCRIPTION="Gesture Recognition And Instantiation Library"
SRC_URI=""
EBZR_REPO_URI="http://bazaar.launchpad.net/~oif-team/lib${MY_PN}/trunk"

HOMEPAGE="https://launchpad.net/libgrip"
KEYWORDS=""
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
