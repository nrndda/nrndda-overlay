# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/ca-certificates/ca-certificates-20110502-r4.ebuild,v 1.3 2011/09/07 16:31:55 grobian Exp $

EAPI="4"

DESCRIPTION="Corel's version of RAW Photo converter"
HOMEPAGE="http://www.corel.com/corel/product/index.jsp?pid=prod4670071"
SRC_URI="amd64? ( http://www.corel.com/akdlm/6763/downloads/AfterShotPro/1/PF/AfterShotPro_amd64.deb )
	x86? ( http://www.corel.com/akdlm/6763/downloads/AfterShotPro/1/PF/AfterShotPro_i386.deb )"

LICENSE="EULA"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
RESTRICT="fetch"

DEPEND=""
RDEPEND="${DEPEND}
	x86? ( virtual/glu
	x11-libs/libXdmcp
	x11-libs/libXext
	media-libs/freetype
	media-libs/freetype
	dev-libs/expat
	media-libs/libpng
	media-libs/mesa
	dev-libs/glib
	media-libs/libpng )
	amd64? ( app-emulation/emul-linux-x86-baselibs
	app-emulation/emul-linux-x86-xlibs )
	"

S=${WORKDIR}

src_unpack() {
	if [[ -n ${EPREFIX} ]] ; then
		# need to perform everything in the offset, #381937
		mkdir -p "./${EPREFIX}"
		cd "./${EPREFIX}" || die
	fi
	unpack ${A}
	unpack ./data.tar.gz
	rm -f control.tar.gz data.tar.gz debian-binary
}

src_install() {
	mv usr "${D}/"
	mv opt "${D}/"
}
