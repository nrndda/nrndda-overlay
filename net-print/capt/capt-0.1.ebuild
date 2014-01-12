# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: 

EAPI="5"
SLOT="0"
inherit eutils

DESCRIPTION="CUPS drivers for Canon LBP-810 and LBP-1120"
SRC_URI="http://www.boichat.ch/nicolas/capt/capt-0.1.tar.gz"
HOMEPAGE="http://www.boichat.ch/nicolas/capt/"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
IUSE=""
LICENSE="GPL-2"

RDEPEND="net-print/cups"

src_prepare() {
	epatch "${FILESDIR}"/path.patch || die
}

src_install() {
	insinto /usr/share/ppd/Canon/
	doins "${S}"/ppd/*.ppd

	dobin "${S}"/capt-print
	dobin "${S}"/capt
}
 
pkg_postinst() {
        echo
        elog "Make simlink /dev/usb/canon into your /dev/usb/lp*"
        echo
}

