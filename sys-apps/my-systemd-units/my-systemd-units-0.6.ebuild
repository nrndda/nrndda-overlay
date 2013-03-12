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
IUSE_MASKS="mask_auditd mask_mysql.target mask_dbus.target mask_networking.target mask_plymouth mask_display-manager"
IUSE="apache2 proftpd uptimed rsyncd distccd br0 hostapd haveged hwclock kdm lvm microcode_ctl \
	ntp git syslog-ng iptables nfs samba vixie-cron rtorrent screen \
	no_tmp_as_tmpfs zram php-fpm mediatomb fail2ban nut flexlm ${IUSE_STUBS} ${IUSE_MASKS}"

DEPEND="sys-apps/systemd
	apache2? ( www-servers/apache )
	distccd? ( sys-devel/distcc )
	git? ( dev-vcs/git )
	br0? ( net-misc/bridge-utils )
	hostapd? ( net-wireless/hostapd )
	haveged? ( sys-apps/haveged )
	hwclock? ( sys-apps/util-linux )
	kdm? ( kde-base/kdm )
	lvm? ( sys-fs/lvm2 )
	proftpd? ( net-ftp/proftpd )
	iptables? ( net-firewall/iptables )
	mediatomb? ( net-misc/mediatomb )
	microcode_ctl? ( sys-apps/microcode-ctl )
	ntp? ( || ( net-misc/ntp net-misc/openntpd sys-apps/busybox ) )
	samba? ( net-fs/samba )
	nfs? ( net-fs/nfs-utils )
	rtorrent? ( net-p2p/rtorrent app-misc/screen )
	rsyncd? ( net-misc/rsync )
	screen? ( app-misc/screen )
	syslog-ng? ( app-admin/syslog-ng )
	vixie-cron? ( sys-process/vixie-cron )
	fail2ban? ( net-analyzer/fail2ban )
	nut? ( sys-power/nut )
	uptimed? ( app-misc/uptimed )"

SOURCE_SERVICES_DIR="${FILESDIR}/services"
SOURCE_TMPFILES_DIR="${FILESDIR}/tmpfiles"
SOURCE_MOUNTS_DIR="${FILESDIR}/mounts"
SOURCE_SOCKETS_DIR="${FILESDIR}/sockets"
SOURCE_PATH_DIR="${FILESDIR}/path"
SOURCE_TARGETS_DIR="${FILESDIR}/targets"

DESTINATION_SERVICES_DIR="/etc/systemd/system"
DESTINATION_TMPFILES_DIR="/etc/tmpfiles.d"
DESTINATION_MOUNTS_DIR="/etc/systemd/system"
DESTINATION_SOCKETS_DIR="/etc/systemd/system"
DESTINATION_PATH_DIR="/etc/systemd/system"
DESTINATION_TARGETS_DIR="/etc/systemd/system"

install_service() {
	insinto "${DESTINATION_SERVICES_DIR}"
	dodir "${DESTINATION_SERVICES_DIR}"
	doins "${SOURCE_SERVICES_DIR}"/$1
}
install_tmpfile() {
	insinto "${DESTINATION_TMPFILES_DIR}"
	dodir "${DESTINATION_TMPFILES_DIR}"
	doins "${SOURCE_TMPFILES_DIR}"/$1
}
install_mount() {
	insinto "${DESTINATION_MOUNTS_DIR}"
	dodir "${DESTINATION_MOUNTS_DIR}"
	doins "${SOURCE_MOUNTS_DIR}"/$1
}
install_socket() {
	insinto "${DESTINATION_SOCKETS_DIR}"
	dodir "${DESTINATION_SOCKETS_DIR}"
	doins "${SOURCE_SOCKETS_DIR}"/$1
}
install_path() {
	insinto "${DESTINATION_PATH_DIR}"
	dodir "${DESTINATION_PATH_DIR}"
	doins "${SOURCE_PATH_DIR}"/$1
}
install_target() {
	insinto "${DESTINATION_TARGETS_DIR}"
	dodir "${DESTINATION_TARGETS_DIR}"
	doins "${SOURCE_TARGETS_DIR}"/$1
}

src_install() {
        install_tmpfile uptimed.conf || die "install_tmpfile failed"
	install_service configure-printer@.service || die "install_service failed"

	for i in mediatomb php-fpm haveged hwclock microcode_ctl kdm lvm syslog-ng vixie-cron zram apache2 uptimed rsyncd ; do
		if use $i; then
			install_service $i.service || die "install_service failed"
		fi
	done
	if use br0; then
		install_service br0_static.service || die "install_service failed"
		install_service br0_dynamic.service || die "install_service failed"
	fi
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
	if use proftpd ; then
		install_service proftpd.service || die "install_service failed"
		install_tmpfile proftpd.conf || die "install_tmpfile failed"
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
		dosym /dev/null "${DESTINATION_SERVICES_DIR}"/auditd.service || die "dosym failed"
	fi
	if use mask_mysql.target; then
		dosym /dev/null "${DESTINATION_TARGETS_DIR}"/mysql.target || die "dosym failed"
	fi
	if use mask_dbus.target; then
		dosym /dev/null "${DESTINATION_TARGETS_DIR}"/dbus.target || die "dosym failed"
	fi
	if use mask_networking.target; then
		dosym /dev/null "${DESTINATION_TARGETS_DIR}"/networking.target || die "dosym failed"
	fi
	if use mask_plymouth; then
		dosym /dev/null "${DESTINATION_SERVICES_DIR}"/plymouth-quit-wait.service || die "dosym failed"
		dosym /dev/null "${DESTINATION_SERVICES_DIR}"/plymouth-quit.service || die "dosym failed"
		dosym /dev/null "${DESTINATION_SERVICES_DIR}"/plymouth-start.service || die "dosym failed"
	fi
	if use mask_display-manager; then
		dosym /dev/null "${DESTINATION_SERVICES_DIR}"/display-manager.service || die "dosym failed"
	fi


	if use no_tmp_as_tmpfs ; then 
		dosym /dev/null "${DESTINATION_MOUNTS_DIR}"/tmp.mount
	fi

	if use vixie-cron; then
		dosym "${DESTINATION_SERVICES_DIR}"/vixie-cron.service "${DESTINATION_SERVICES_DIR}"/cron.service || die "dosym failed"
	fi

	if use syslog-ng; then
		dosym "${DESTINATION_SERVICES_DIR}"/syslog-ng.service "${DESTINATION_SERVICES_DIR}"/syslog.service || die "dosym failed"
	fi
	
	einfo "Services installed into ${DESTINATION_SERVICES_DIR}"
	einfo "Sockets installed into ${DESTINATION_SOCKETS_DIR}"
	einfo "Tmpfiles installed into ${DESTINATION_TMPFILES_DIR}"
	einfo "Targets installed into ${DESTINATION_TARGETS_DIR}"
	einfo "Pathes installed into ${DESTINATION_PATH_DIR}"
	einfo "Mounts installed into ${DESTINATION_MOUNTS_DIR}"
	
	einfo
	einfo "For enable unit type:"
	einfo "systemctl enable unit.service"
	einfo
	einfo "For start unit:"
	einfo "systemctl start unit.service"
	einfo

}
