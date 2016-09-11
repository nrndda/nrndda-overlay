# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit base bzr

MY_P="${P:7}"
MY_PN="${PN:7}"

DESCRIPTION="Gesture Recognition And Instantiation Library"
SRC_URI=""
EBZR_REPO_URI="http://bazaar.launchpad.net/${MY_PN}/trunk"

RESTRICT="mirror"

HOMEPAGE="https://launchpad.net/grail"
KEYWORDS=""
SLOT="0"
LICENSE="GPV-3"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}
	sys-libs/mtdev
	x11-misc/utouch-evemu
	x11-libs/utouch-frame
	"
S="${WORKDIR}/${MY_P}"
