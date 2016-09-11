# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils base bzr autotools

MY_P="${P:7}"
MY_PN="${PN:7}"

DESCRIPTION="Gesture Recognition And Instantiation Library"
SRC_URI=""
EBZR_REPO_URI="https://code.launchpad.net/~oif-team/lib${MY_PN}/trunk"

HOMEPAGE="https://launchpad.net/libgrip"
KEYWORDS=""
SLOT="0"
LICENSE="GPV-3"
IUSE="doc"

RDEPEND=""
DEPEND="${RDEPEND}
	>=x11-libs/gtk+-3.0.8:3
	>=x11-libs/utouch-geis-2.1.1
	dev-libs/gobject-introspection
	"
#S="${WORKDIR}/${MY_P}"

src_prepare() {
	cd ${S}
	if ! use doc; then
                sed -i -e '/gtk-doc.make/d' Makefile.am || die
                sed -i 's/--enable-gtk-doc//' autogen.sh || die
                sed -i 's/--enable-gtk-doc//' Makefile.am || die
                sed -i 's/.*gtk-doc.make.*/EXTRA_DIST = /' doc/reference/Makefile.am || die
        fi
	eautoreconf || die "failed running autoreconf"
}
