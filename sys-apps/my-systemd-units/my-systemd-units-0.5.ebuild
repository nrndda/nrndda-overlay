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
IUSE_MASKS="mask_auditd mask_mysql.target mask_dbus.target mask_plymouth mask_display-manager"
IUSE="distccd eth wlan br0_dynamic br0_static hostapd hwclock kdm lvm microcode_ctl \
	ntp git syslog-ng iptables nfs samba vixie-cron rtorrent screen \
	no_tmp_as_tmpfs zram php-fpm mediatomb fail2ban nut flexlm ${IUSE_STUBS} ${IUSE_MASKS}"

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

source_service_dir="${FILESDIR}"/services"
source_tmpfiles_dir="${FILESDIR}"/tmpfiles"
source_mounts_dir="${FILESDIR}"/mounts"
source_sockets_dir="${FILESDIR}"/sockets"
source_path_dir="${FILESDIR}"/path"
source_targets_dir="${FILESDIR}"/targets"

destination_service_dir="/etc/systemd/system"
destination_tmpfiles_dir="/etc/tmpfiles.d"
destination_mount_dir="/etc/systemd/system"
destination_sockets_dir="/etc/systemd/system"
destination_path_dir="/etc/systemd/system"
destination_targets_dir="/etc/systemd/system"

install_service() {
	insinto "${destination_service_dir}"
	dodir "${destination_service_dir}"
	doins "${source_service_dir}"/$1
}
install_tmpfile() {
	insinto "${destination_tmpfiles_dir}"
	dodir "${destination_tmpfiles_dir}"
	doins "${source_tmpfiles_dir}"/$1
}
install_mount() {
	insinto "${destination_mount_dir}"
	dodir "${destination_mount_dir}"
	doins "${source_mounts_dir}"/$1
}
install_socket() {
	insinto "${destination_sockets_dir}"
	dodir "${destination_sockets_dir}"
	doins "${source_sockets_dir}"/$1
}
install_path() {
	insinto "${destination_path_dir}"
	dodir "${destination_path_dir}"
	doins "${source_path_dir}"/$1
}
install_target() {
	insinto "${destination_targets_dir}"
	dodir "${destination_targets_dir}"
	doins "${source_targets_dir}"/$1
}

src_install() {
        install_tmpfile uptimed.conf || die "install_tmpfile failed"
	install_service configure-printer@.service || die "install_service failed"

	for i in mediatomb php-fpm br0_dynamic br0_static hwclock microcode_ctl kdm lvm syslog-ng vixie-cron zram ; do
		if use $i; then
			install_service $i.service || die "install_service failed"
		fi
	done
	if use distccd ; then
		install_service distccd.service || die "install_service failed"
		install_service distccd@.service || die "install_service failed"
		install_socket distccd.socket || die "install_socket failed"
		install_tmpfile distccd.conf || die "install_tmpfile failed"
		install_tmpfile distccd@.conf || die "install_tmpfile failed"
	fi
	if use hostapd ; then
		install_service hostapd.service || die "install_service failed"
		install_tmpfile hostapd.conf || die "install_tmpfile failed"
	fi
	if use git ; then
		install_service git-daemon@.service || die "install_service failed"
		install_service git-daemon.service || die "install_service failed"
		install_socket git-daemon.socket || die "install_socket failed"
	fi
	if use ntp ; then
		install_service busybox_ntpd_client.service || die "install_service failed"
		install_service ntp-client.service || die "install_service failed"
		install_service ntpd.service || die "install_service failed"
	fi
	if use nut ; then
		install_service nut-driver.service || die "install_service failed"
		install_service nut-monitor.service || die "install_service failed"
		install_service nut-server.service || die "install_service failed"
	fi
	if use eth ; then
		install_service eth0.service || die "install_service failed"
		install_service eth@.service || die "install_service failed"
	fi
	if use wlan ; then
		install_service wlan0.service || die "install_service failed"
		install_service wlan@.service || die "install_service failed"
	fi
	if use iptables ; then
		install_service iptables.service || die "install_service failed"
		install_service ip6tables.service || die "install_service failed"
		dosbin "${FILESDIR}"/iptables-stop || die "dosbin failed"
	fi
	if use flexlm ; then
		install_service flexlm.service || die "install_service failed"
		dosbin "${FILESDIR}"/flexlm || die "dosbin failed"
	fi
	if use nfs ; then
		install_service nfsd.service || die "install_service failed"
		install_service rpcbind.service || die "install_service failed"
		install_service rpc.gssd.service || die "install_service failed"
		install_service rpc.idmapd.service || die "install_service failed"
		install_service rpc.mountd.service || die "install_service failed"
		install_service rpc.statd.service || die "install_service failed"
		install_service sm-notify.service || die "install_service failed"

		install_target nfs3_client.target || die "install_target failed"
		install_target nfs4_client.target || die "install_target failed"
	fi
	if use rtorrent ; then
		install_service rtorrent.service || die "install_service failed"
		install_path rtorrent.path || die "install_service failed"
	fi
	if use samba ; then
		install_service samba.service || die "install_service failed"
		install_service nmbd.service || die "install_service failed"
		install_tmpfile samba.conf || die "install_tmpfile failed"
	fi
	if use screen ; then
		install_service screen@.service || die "install_service failed"
	fi
	if use fail2ban ; then
		install_service fail2ban.service || die "install_service failed"
		install_tmpfile fail2ban.conf || die "install_tmpfile failed"
	fi


	if use stub_dbus ; then
		install_target dbus.target || die "install_target failed"
	fi
	if use stub_auditd ; then 
		install_service auditd.service || die "install_service failed"
	fi
	if use stub_plymouth ; then
		install_service plymouth-quit-wait.service || die "install_service failed"
		install_service plymouth-quit.service || die "install_service failed"
		install_service plymouth-start.service || die "install_service failed"
	fi


	if use mask_auditd; then
		dosym /dev/null "${destination_service_dir}"/auditd.service || die "dosym failed"
	fi
	if use mask_mysql.target; then
		dosym /dev/null "${destination_target_dir}"/mysql.target || die "dosym failed"
	fi
	if use mask_dbus.target; then
		dosym /dev/null "${destination_target_dir}"/dbus.target || die "dosym failed"
	fi
	if use mask_plymouth; then
		dosym /dev/null "${destination_service_dir}"/plymouth-quit-wait.service || die "dosym failed"
		dosym /dev/null "${destination_service_dir}"/plymouth-quit.service || die "dosym failed"
		dosym /dev/null "${destination_service_dir}"/plymouth-start.service || die "dosym failed"
	fi
	if use mask_display-manager; then
		dosym /dev/null "${destination_service_dir}"/display-manager.service || die "dosym failed"
	fi


	if use no_tmp_as_tmpfs ; then 
		dosym /dev/null "${destination_mount_dir}"/tmp.mount
	fi

	if use br0_dynamic && use br0_static; then
		eerror "Only one use (br0_dynamic,br0_static) allowed."
	fi

	for i in br0_dynamic br0_static ; do
		if use $i; then
			dosym "${destination_service_dir}"/$i.service "${destination_service_dir}"/br0.service || die "dosym failed"
		fi
	done

	if use vixie-cron; then
		dosym "${destination_service_dir}"/vixie-cron.service "${destination_service_dir}"/cron.service || die "dosym failed"
	fi

	if use syslog-ng; then
		dosym "${destination_service_dir}"/syslog-ng.service "${destination_service_dir}"/syslog.service || die "dosym failed"
	fi
	
	einfo
	einfo "For enable unit type:"
	einfo "systemctl enable unit.service"
	einfo
	einfo "For start unit:"
	einfo "systemctl start unit.service"
	einfo

}
