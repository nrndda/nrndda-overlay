# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

inherit eutils

DESCRIPTION="My units for systemd"
HOMEPAGE="http://nrndda.mine.nu"
#SRC_URI=""
#SRC_URI="ftp://nrndda.mine.nu/Apps/my_systemd_units-0.1.tar.gz
#	ftp://10.0.0.2/Apps/my_systemd_units-0.1.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE_STUBS="stub_auditd stub_dbus stub_plymouth"
IUSE="distccd eth wlan br0_dynamic br0_static hostapd hwclock kdm lvm microcode_ctl \
	ntp syslog-ng iptables nfs samba vixie-cron configure-printer rtorrent screen \
	 zram php-fpm mediatomb ${IUSE_STUBS}"

#REQUIRED_USE="
#        ?? ( br0_dynamic br0_static )
#"

DEPEND="sys-apps/systemd
	distccd? ( sys-devel/distcc )
	br0_dynamic? ( net-misc/bridge-utils )
	br0_static? ( net-misc/bridge-utils )
	hostapd? ( net-wireless/hostapd )
	hwclock? ( sys-apps/util-linux )
	kdm? ( kde-base/kdm )
	lvm? ( sys-fs/lvm2 )
	iptables? ( net-firewall/iptables )
	mediatomb? ( net-misc/mediatomb )
	microcode_ctl? ( sys-apps/microcode-ctl )
	ntp? ( || ( net-misc/ntp net-misc/openntpd sys-apps/busybox ) )
	samba? ( net-fs/samba )
	nfs? ( net-fs/nfs-utils )
	rtorrent? ( net-p2p/rtorrent app-misc/screen )
	screen? ( app-misc/screen )
	syslog-ng? ( app-admin/syslog-ng )
	vixie-cron? ( sys-process/vixie-cron )"

install_dir="/etc/systemd/system/"

src_install() {
	insinto "${install_dir}"
	dodir "${install_dir}"

	for i in mediatomb php-fpm br0_dynamic br0_static hostapd hwclock microcode_ctl kdm lvm syslog-ng vixie-cron zram ; do
		if use $i; then
			doins "${FILESDIR}"/$i.service || die "doins failed"
		fi
	done
	if use distccd ; then
		doins "${FILESDIR}"/distccd.service || die "doins failed"
		doins "${FILESDIR}"/distccd@.service || die "doins failed"
		doins "${FILESDIR}"/distccd.socket || die "doins failed"
	fi
	if use ntp ; then
		doins "${FILESDIR}"/busybox_ntpd_client.service || die "doins failed"
		doins "${FILESDIR}"/ntp-client.service || die "doins failed"
		doins "${FILESDIR}"/ntpd.service || die "doins failed"
	fi
	if use configure-printer ; then
		doins "${FILESDIR}"/configure-printer@.service || die "doins failed"
	fi
	if use eth ; then
		doins "${FILESDIR}"/eth0.service || die "doins failed"
		doins "${FILESDIR}"/eth@.service || die "doins failed"
	fi
	if use wlan ; then
		doins "${FILESDIR}"/wlan0.service || die "doins failed"
		doins "${FILESDIR}"/wlan@.service || die "doins failed"
	fi
	if use iptables ; then
		doins "${FILESDIR}"/iptables.service || die "doins failed"
		doins "${FILESDIR}"/ip6tables.service || die "doins failed"
		dosbin "${FILESDIR}"/iptables-stop || die "dosbin failed"
	fi
	if use nfs ; then
		doins "${FILESDIR}"/nfsd.service || die "doins failed"
		doins "${FILESDIR}"/rpcbind.service || die "doins failed"
		doins "${FILESDIR}"/rpc.gssd.service || die "doins failed"
		doins "${FILESDIR}"/rpc.idmapd.service || die "doins failed"
		doins "${FILESDIR}"/rpc.mountd.service || die "doins failed"
		doins "${FILESDIR}"/rpc.statd.service || die "doins failed"
		doins "${FILESDIR}"/sm-notify.service || die "doins failed"

		doins "${FILESDIR}"/nfs3_client.target || die "doins failed"
		doins "${FILESDIR}"/nfs4_client.target || die "doins failed"
	fi
	if use rtorrent ; then
		doins "${FILESDIR}"/rtorrent.service || die "doins failed"
		doins "${FILESDIR}"/rtorrent.path || die "doins failed"
	fi
	if use samba ; then
		doins "${FILESDIR}"/samba.service || die "doins failed"
		doins "${FILESDIR}"/nmbd.service || die "doins failed"
	fi
	if use screen ; then
		doins "${FILESDIR}"/screen@.service || die "doins failed"
	fi



	if use stub_dbus ; then
		doins "${FILESDIR}"/dbus.target || die "doins failed"
	fi
	if use stub_auditd ; then 
		doins "${FILESDIR}"/auditd.service || die "doins failed"
	fi
	if use stub_plymouth ; then
		doins "${FILESDIR}"/plymouth-quit-wait.service || die "doins failed"
		doins "${FILESDIR}"/plymouth-start.service || die "doins failed"
	fi


	if use br0_dynamic && use br0_static; then
		eerror "Only one use (br0_dynamic,br0_static) allowed."
	fi

	for i in br0_dynamic br0_static ; do
		if use $i; then
			dosym "${install_dir}"/$i.service "${install_dir}"/br0.service || die "dosym failed"
		fi
	done

	if use vixie-cron; then
		dosym "${install_dir}"/vixie-cron.service "${install_dir}"/cron.service || die "dosym failed"
	fi

	if use syslog-ng; then
		dosym "${install_dir}"/syslog-ng.service "${install_dir}"/syslog.service || die "dosym failed"
	fi
	
	einfo
	einfo "For enable unit type:"
	einfo "systemctl enable unit.service"
	einfo
	einfo "For start unit:"
	einfo "systemctl start unit.service"
	einfo

}
