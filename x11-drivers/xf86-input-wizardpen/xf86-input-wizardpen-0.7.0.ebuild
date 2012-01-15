# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit linux-mod eutils

DESCRIPTION="Driver for Genius Wizardpen Tablets"
HOMEPAGE="http://eva.fit.vutbr.cz/~xhorak28/index.php?page=WizardPen_Driver"
SRC_URI="http://linuxgenius.googlecode.com/files/wizardpen-0.7.0-alpha2.tar.gz"

DEPEND=""
RDEPEND="x11-base/xorg-x11"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"

IUSE="usb"

RESTRICT="nomirror"

src_unpack() {
#	if kernel_is 2 4; then
#		die "You must use 2.6.X kernel with ${PN}"
#	fi
#	if use usb; then
#		if ! linux_chkconfig_module INPUT_EVDEV
#		then
#			if ! linux_chkconfig_present INPUT_EVDEV
#	        	then
#				eerror "${PN} requires evdev support for USB tablets"
#				eerror "In your .config: CONFIG_INPUT_EVDEV=y or CONFIG_INPUT_EVDEV=m"
#				eerror "Through 'make menuconfig':"
#	                        eerror "Device Drivers-> Input device support-> [*] Event interface or"
#	                        eerror "Device Drivers-> Input device support-> [M] Event interface"
#	                        eerror ""
#	                        eerror "If compiled as modules add evdev to /etc/modules.autoload/kernel-2.6"
#	                        die "Please build evdev support first"
#			fi
#		fi
#	fi
#	if use usb; then
#		if ! linux_chkconfig_present USB_HIDINPUT
#		then
#			eerror "${PN} requires USB Human Interface Device support for USB tablets"
#			eerror "In your .config: CONFIG_USB_HID=y or CONFIG_USB_HID=m and CONFIG_USB_HIDINPUT=y"
#			eerror "Through 'make menuconfig':"
#			eerror "Device Drivers-> USB support-> [*] USB Human Interface Device (full HID) support or"
#			eerror "Device Drivers-> USB support-> [M] USB Human Interface Device (full HID) support and"
#			eerror "Device Drivers-> USB support-> [*]   HID input layer support"
#			eerror ""
#			eerror "If compiled as modules add usbhid to /etc/modules.autoload/kernel-2.6"
#			die "Please build USB HID support first"
#		fi
#	fi
	unpack ${A}
	cd "${WORKDIR}/wizardpen-0.7.0-alpha2"
#	epatch ${FILESDIR}/tablet-not-connected.patch
}

src_compile() {
#	xmkmf
#	make

	cd "${WORKDIR}/wizardpen-0.7.0-alpha2"
	econf || die "econf failed"
	emake || die "emake failed"

#	cd calibrate
#	make
#	cd ${S}
}

src_install() {
#	exeinto /usr/X11R6/lib/modules/drivers
#	doexe wizardpen_drv.*
	
	cd "${WORKDIR}/wizardpen-0.7.0-alpha2"
	exeinto /usr/lib/xorg/modules/drivers/
	doexe src/.libs/wizardpen_drv.so
		
	exeinto /usr/bin
	doexe calibrate/wizardpen-calibrate

	dodoc BUGS ChangeLog README INSTALL TODO
	newdoc calibrate/README README.calibrate
	newdoc calibrate/ChangeLog ChangeLog.calibrate

	doman man/wizardpen.4
	
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
