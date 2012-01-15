# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit linux-mod eutils

DESCRIPTION="Driver for Genius Wizardpen Tablets"
HOMEPAGE="http://eva.fit.vutbr.cz/~xhorak28/index.php?page=WizardPen_Driver"
SRC_URI="http://linuxgenius.googlecode.com/files/${P}.tar.gz"

DEPEND=""
RDEPEND="x11-base/xorg-x11"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"

IUSE="usb"

RESTRICT="nomirror"

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/tablet-not-connected.patch
}

src_compile() {
	xmkmf
	make

	cd calibrate
	make
	cd ${S}
}

src_install() {
	exeinto /usr/X11R6/lib/modules/drivers
	doexe wizardpen_drv.*

	exeinto /usr/bin
	doexe calibrate/wizardpen-calibrate

	dodoc BUGS ChangeLog README INSTALL TODO
	newdoc calibrate/README README.calibrate
	newdoc calibrate/ChangeLog ChangeLog.calibrate

	insinto /etc/udev/rules.d/
	newins ${FILESDIR}/udev.rules 45-wizardpen.rules
}

pkg_postinst() {
	einfo ""
	einfo "For USB tablet you should use /dev/wizardpen as tablet device and add"
	einfo "	Section		\"InputDevice\""
   	einfo "	Identifier	\"WizardPen Tablet\""
	einfo "	Option		\"Device\"	\"/dev/wizardpen\""
	einfo "	Driver		\"wizardpen\""
	einfo "	EndSection"
	einfo "in /etc/X11/xorg.conf InputDevice section."
	einfo "For serial tablets use /dev/ttySx where x is number of serial port device."
	einfo "For both USB and serial tablets you must add"
	einfo "	InputDevice	\"WizardPen Tablet\"	\"AlwaysCore\""
	einfo "in ServerLayout section of xorg.conf."
	einfo "If you don'n want X to crash on startup when Tablet is not present just add"
	einfo "Option \"AllowMouseOpenFail\" \"true\" in ServerFlags section of xorg.conf"
	einfo ""
	einfo "You can set tablet working area useing wizardpen-calibrate tool, see README and INSTALL"
	einfo "files from /usr/share/doc/${P} for more details."
	einfo ""
}
