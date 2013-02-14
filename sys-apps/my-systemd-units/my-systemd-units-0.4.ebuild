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
	ntp git syslog-ng iptables nfs samba vixie-cron rtorrent screen \
	no_tmp_as_tmpfs zram php-fpm mediatomb fail2ban nut flexlm ${IUSE_STUBS}"

#REQUIRED_USE="
#        ?? ( br0_dynamic br0_static )
#"

DEPEND="sys-apps/systemd
	distccd? ( sys-devel/distcc )
	git? ( dev-vcs/git )
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
	vixie-cron? ( sys-process/vixie-cron )
	fail2ban? ( net-analyzer/fail2ban )
	nut? ( sys-power/nut )"

install_dir="/etc/systemd/system"

src_install() {
        insinto "/etc/tmpfiles.d"
        dodir "/etc/tmpfiles.d"
        doins "${FILESDIR}"/tmpfiles.d/uptimed.conf || die "doins failed"
	insinto "${install_dir}"
	dodir "${install_dir}"

	for i in mediatomb php-fpm br0_dynamic br0_static hwclock microcode_ctl kdm lvm syslog-ng vixie-cron zram ; do
		if use $i; then
			doins "${FILESDIR}"/services/$i.service || die "doins failed"
		fi
	done
	if use distccd ; then
		doins "${FILESDIR}"/services/distccd.service || die "doins failed"
		doins "${FILESDIR}"/services/distccd@.service || die "doins failed"
		doins "${FILESDIR}"/sockets/distccd.socket || die "doins failed"
	        insinto "/etc/tmpfiles.d"
        	dodir "/etc/tmpfiles.d"		
		doins "${FILESDIR}"/tmpfiles.d/distccd.conf || die "doins failed"
		doins "${FILESDIR}"/tmpfiles.d/distccd@.conf || die "doins failed"
	        insinto "${install_dir}"
	        dodir "${install_dir}"
	fi
	if use hostapd ; then
		doins "${FILESDIR}"/services/hostapd.service || die "doins failed"
	        insinto "/etc/tmpfiles.d"
        	dodir "/etc/tmpfiles.d"		
		doins "${FILESDIR}"/tmpfiles.d/hostapd.conf || die "doins failed"
	        insinto "${install_dir}"
	        dodir "${install_dir}"
	fi
	if use git ; then
		doins  "${FILESDIR}"/services/git-daemon@.service || die "doins failed"
		doins  "${FILESDIR}"/services/git-daemon.service || die "doins failed"
		doins  "${FILESDIR}"/sockets/git-daemon.socket || die "doins failed"
	fi
	if use ntp ; then
		doins "${FILESDIR}"/services/busybox_ntpd_client.service || die "doins failed"
		doins "${FILESDIR}"/services/ntp-client.service || die "doins failed"
		doins "${FILESDIR}"/services/ntpd.service || die "doins failed"
	fi
	if use nut ; then
		doins "${FILESDIR}"/services/nut-driver.service || die "doins failed"
		doins "${FILESDIR}"/services/nut-monitor.service || die "doins failed"
		doins "${FILESDIR}"/services/nut-server.service || die "doins failed"
	fi
	if use eth ; then
		doins "${FILESDIR}"/services/eth0.service || die "doins failed"
		doins "${FILESDIR}"/services/eth@.service || die "doins failed"
	fi
	if use wlan ; then
		doins "${FILESDIR}"/services/wlan0.service || die "doins failed"
		doins "${FILESDIR}"/services/wlan@.service || die "doins failed"
	fi
	if use iptables ; then
		doins "${FILESDIR}"/services/iptables.service || die "doins failed"
		doins "${FILESDIR}"/services/ip6tables.service || die "doins failed"
		dosbin "${FILESDIR}"/iptables-stop || die "dosbin failed"
	fi
	if use flexlm ; then
		doins "${FILESDIR}"/services/flexlm.service || die "doins failed"
		dosbin "${FILESDIR}"/flexlm || die "dosbin failed"
	fi
	if use nfs ; then
		doins "${FILESDIR}"/services/nfsd.service || die "doins failed"
		doins "${FILESDIR}"/services/rpcbind.service || die "doins failed"
		doins "${FILESDIR}"/services/rpc.gssd.service || die "doins failed"
		doins "${FILESDIR}"/services/rpc.idmapd.service || die "doins failed"
		doins "${FILESDIR}"/services/rpc.mountd.service || die "doins failed"
		doins "${FILESDIR}"/services/rpc.statd.service || die "doins failed"
		doins "${FILESDIR}"/services/sm-notify.service || die "doins failed"

		doins "${FILESDIR}"/targets/nfs3_client.target || die "doins failed"
		doins "${FILESDIR}"/targets/nfs4_client.target || die "doins failed"
	fi
	if use rtorrent ; then
		doins "${FILESDIR}"/services/rtorrent.service || die "doins failed"
		doins "${FILESDIR}"/path/rtorrent.path || die "doins failed"
	fi
	if use samba ; then
		doins "${FILESDIR}"/services/samba.service || die "doins failed"
		doins "${FILESDIR}"/services/nmbd.service || die "doins failed"
	fi
	if use screen ; then
		doins "${FILESDIR}"/services/screen@.service || die "doins failed"
	fi
	if use fail2ban ; then
		doins "${FILESDIR}"/services/fail2ban.service || die "doins failed"
	        insinto "/etc/tmpfiles.d"
        	dodir "/etc/tmpfiles.d"		
		doins "${FILESDIR}"/tmpfiles.d/fail2ban.conf || die "doins failed"
	        insinto "${install_dir}"
	        dodir "${install_dir}"
	fi


	if use stub_dbus ; then
		doins "${FILESDIR}"/targets/dbus.target || die "doins failed"
	fi
	if use stub_auditd ; then 
		doins "${FILESDIR}"/services/auditd.service || die "doins failed"
	fi
	if use stub_plymouth ; then
		doins "${FILESDIR}"/services/plymouth-quit-wait.service || die "doins failed"
		doins "${FILESDIR}"/services/plymouth-start.service || die "doins failed"
	fi

	if use no_tmp_as_tmpfs ; then 
		dosym /dev/null "${install_dir}"/tmp.mount
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
