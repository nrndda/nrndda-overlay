# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit eutils

DESCRIPTION="My units for systemd"
HOMEPAGE="http://nrndda.mine.nu"
SRC_URI=""
#SRC_URI="ftp://nrndda.mine.nu/Apps/my_systemd_units-0.1.tar.gz
#	ftp://10.0.0.2/Apps/my_systemd_units-0.1.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="distccd br0 hostapd inet hwclock microcode_ctl \
	git iptables miniupnpd rtorrent screen hdparm \
	no_tmp_as_tmpfs zram mediatomb ushare flexlm mpd"

DEPEND="sys-apps/systemd
	distccd? ( sys-devel/distcc )
	git? ( dev-vcs/git )
	br0? ( net-misc/bridge-utils )
	hostapd? ( net-wireless/hostapd )
	inet? ( net-dialup/rp-pppoe net-misc/ndisc6 net-firewall/iptables sys-apps/iproute2 )
	hwclock? ( sys-apps/util-linux )
	iptables? ( net-firewall/iptables )
	miniupnpd? ( net-misc/miniupnpd )
	mediatomb? ( net-misc/mediatomb )
	ushare? ( media-video/ushare )
	microcode_ctl? ( sys-apps/microcode-ctl )
	rtorrent? ( net-p2p/rtorrent app-misc/screen )
	screen? ( app-misc/screen )
	hdparm? ( sys-apps/hdparm )
	mpd? ( media-sound/mpd )"

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

src_unpack() {
	#Just for workaround emerge error
	mkdir -p "${S}/${P}"
}

src_install() {
	install_service configure-printer@.service || die "install_service failed"
	install_service cpufreq_governor.service || die "install_service failed"

	mkdir -p "${D}"/etc/systemd/system/getty@tty1.service.d/
	insinto /etc/systemd/system/getty@tty1.service.d/
	doins "${FILESDIR}"/noclear.conf

	for i in mediatomb ushare hwclock microcode_ctl; do
		if use $i; then
			install_service $i.service || die "install_service failed"
		fi
	done
	if use br0; then
		install_service br0@.service || die "install_service failed"
	        exeinto /usr/local/sbin/
	        doexe "${FILESDIR}"/crda_set.sh
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
		install_service hostapd@.service || die "install_service failed"
		install_tmpfile hostapd.conf || die "install_tmpfile failed"
	fi
	if use inet ; then
		install_service inet@.service || die "install_service failed"
		install_service ext_lan@.service || die "install_service failed"
	        exeinto /usr/local/sbin/
	        doexe "${FILESDIR}"/fw_flush_all_rules.sh
	        doexe "${FILESDIR}"/fw_full.sh
	        doexe "${FILESDIR}"/fw_with_dhcpcd_hooks.sh
	fi
	if use hdparm ; then
		install_service hdparm_disableAPM@.service || die "install_service failed"
	fi
	if use git ; then
		install_service git-daemon@.service || die "install_service failed"
		install_service git-daemon.service || die "install_service failed"
	fi
	if use iptables ; then
		install_service iptables.service || die "install_service failed"
		install_service ip6tables.service || die "install_service failed"
		dosbin "${FILESDIR}"/iptables-stop || die "dosbin failed"
	fi
	if use miniupnpd ; then
		install_service miniupnpd.service || die "install_service failed"
		install_tmpfile miniupnpd.conf || die "install_tmpfile failed"
	fi
	if use mpd ; then
		install_service mpd@.service || die "install_service failed"
	fi
	if use flexlm ; then
		install_service flexlm.service || die "install_service failed"
		dosbin "${FILESDIR}"/flexlm || die "dosbin failed"
	fi
	if use rtorrent ; then
		install_service rtorrent.service || die "install_service failed"
		install_path rtorrent.path || die "install_service failed"
	fi
	if use screen ; then
		install_service screen@.service || die "install_service failed"
	fi
	if use zram ; then
		install_service zram.service || die "install_service failed"
		dosbin "${FILESDIR}"/zram || die "dosbin failed"
		dosbin "${FILESDIR}"/zram_statistic || die "dosbin failed"
		newconfd "${FILESDIR}"/zram.conf zram || die "newconfd failed"
	fi


	if use no_tmp_as_tmpfs ; then 
		dosym /dev/null "${DESTINATION_MOUNTS_DIR}"/tmp.mount
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
