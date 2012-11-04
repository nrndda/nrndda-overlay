# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

inherit eutils

DESCRIPTION="My units for systemd"
HOMEPAGE="http://nrndda.mine.nu"
#SRC_URI="ftp://nrndda.mine.nu/Apps/my_systemd_units-0.1.tar.gz
#	ftp://10.0.0.2/Apps/my_systemd_units-0.1.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+auditd_stub +dbus +distccd +eth0 +wlan0 +br0 +hostapd +hwclock +kdm +microcode_ctl \
	+ntp-client +plymouth-quit-wait_stub +plymouth-start_stub +syslog-ng \
	+vixie-cron +zram"

DEPEND="sys-apps/systemd
	dbus? ( sys-apps/dbus )
	distccd? ( distccdsys-devel/distcc )
	br0? ( net-misc/bridge-utils )
	hostapd? ( net-wireless/hostapd )
	hwclock? ( sys-apps/util-linux )
	kdm? ( kde-base/kdm )
	microcode_ctl? ( sys-apps/microcode-ctl )
	ntp-client? ( net-misc/ntp )
	syslog-ng? ( app-admin/syslog-ng )
	vixie-cron? ( sys-process/vixie-cron )"

install_dir="/etc/systems/system/"

src_install() {
	insinto "${dir}"

	for i in auditd_stub eth0 wlan0 br0 hostapd hwclock microcode_ctl \
	  ntp-client plymouth-quit-wait_stub plymouth-start_stub syslog-ng \
	  vixie-cron zram ; do
		if use $i; then
			doins "${FILESDIR}"/$i.service || die "doins failed"
		fi
	done

	if use distccd ; then
		doins "${FILESDIR}"/distccd.service || die "doins failed"
		doins "${FILESDIR}"/distccd@.service || die "doins failed"
		doins "${FILESDIR}"/distccd.socket || die "doins failed"
	fi

	if use dbus ; then
		doins "${FILESDIR}"/dbus.target || die "doins failed"
	fi

	einfo
	einfo "For enable unit type:"
	einfo "systemctl enable unit.service"
	einfo
	einfo "For start unit:"
	einfo "systemctl start unit.service"
	einfo

}
