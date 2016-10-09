# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit eutils user systemd

DESCRIPTION="My units for systemd"
HOMEPAGE="http://nrndda.mine.nu"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="cgroups cpupower distccd br0 hostapd inet dhcpcd_firewall_hook hwclock microcode_ctl \
	git iptables miniupnpd minissdpd rtorrent screen hdparm \
	no_tmp_as_tmpfs zram mediatomb ushare flexlm mpd vfio touchegg"

DEPEND="sys-apps/systemd
	cgroups? ( dev-libs/libcgroup )
	cpupower? ( sys-power/cpupower )
	distccd? ( sys-devel/distcc )
	git? ( dev-vcs/git )
	br0? ( net-misc/bridge-utils )
	hostapd? ( net-wireless/hostapd )
	inet? ( net-dialup/rp-pppoe net-misc/ndisc6 net-firewall/iptables sys-apps/iproute2 )
	dhcpcd_firewall_hook? ( net-misc/dhcpcd )
	hwclock? ( sys-apps/util-linux )
	iptables? ( net-firewall/iptables )
	miniupnpd? ( net-misc/miniupnpd )
	minissdpd? ( net-misc/minissdpd )
	mediatomb? ( net-misc/mediatomb )
	ushare? ( media-video/ushare )
	microcode_ctl? ( sys-apps/microcode-ctl )
	rtorrent? ( net-p2p/rtorrent app-misc/screen )
	screen? ( app-misc/screen )
	hdparm? ( sys-apps/hdparm )
	mpd? ( media-sound/mpd )
	touchegg? ( x11-misc/touchegg )"

SOURCE_SERVICES_DIR="${FILESDIR}/services"
SOURCE_TMPFILES_DIR="${FILESDIR}/tmpfiles"
SOURCE_MOUNTS_DIR="${FILESDIR}/mounts"
SOURCE_SOCKETS_DIR="${FILESDIR}/sockets"
SOURCE_PATH_DIR="${FILESDIR}/path"
SOURCE_TARGETS_DIR="${FILESDIR}/targets"

src_unpack() {
	#Just for workaround emerge error
	mkdir -p "${S}/${P}"
}

src_install() {
	systemd_doinit configure-printer@.service
	systemd_doinit cpufreq_governor@.service
	systemd_doinit wpa_supplicant.service
	systemd_doinit autosuspend_usb@.service
	systemd_doinit autosuspend_pci@.service
	systemd_doinit autosuspend_pcie@.service
	systemd_doinit disable_wifi_powersave@.service

	systemd_install_serviced "${FILESDIR}"/noclear.conf getty@tty1.service.d

	exeinto /usr/local/sbin/
	doexe "${FILESDIR}"/ssh_login.sh
	exeinto /etc/ssh/
	doexe "${FILESDIR}"/sshrc
	insinto /usr/local/sbin/
	doins "${FILESDIR}"/KDE-Im-Phone-Ring.wav
	doins "${FILESDIR}"/stock_dialog_warning_48.png

	for i in mediatomb ushare hwclock microcode_ctl cpupower; do
		if use $i; then
			systemd_doinit $i.service
		fi
	done
	if use cgroups; then
		systemd_doinit cgconfig.service
		systemd_doinit cgrules.service
	fi

	if use br0; then
		systemd_doinit br0@.service
		systemd_doinit br0.target
	fi
	if use distccd ; then
		systemd_doinit distccd.service
		systemd_doinit distccd@.service
		systemd_doinit distccd.socket
		systemd_dotmpfilesd distccd.conf
		systemd_dotmpfilesd distccd@.conf
	fi
	if use hostapd ; then
		systemd_doinit hostapd.service
		systemd_doinit hostapd@.service
		systemd_doinit hostapd.target
		systemd_dotmpfilesd hostapd.conf
	        exeinto /usr/local/sbin/
	        doexe "${FILESDIR}"/crda_set.sh
	fi
	if use inet ; then
		systemd_doinit inet@.service
		systemd_doinit inet.target
		systemd_doinit ext_lan@.service
		systemd_doinit ext_lan.target
		systemd_doinit firewall.service
		systemd_doinit firewall_inet.service
	        exeinto /usr/local/sbin/
	        doexe "${FILESDIR}"/fw_flush_all_rules.sh
	        doexe "${FILESDIR}"/fw_full.sh
	        doexe "${FILESDIR}"/fw_full_with_ip.sh
	        doexe "${FILESDIR}"/fw_with_dhcpcd_hooks.sh
	fi
	if use dhcpcd_firewall_hook ; then
		insinto /lib/dhcpcd/dhcpcd-hooks/
		doins "${FILESDIR}"/99-dhcpcd_fw_hook.sh
	fi
	if use hdparm ; then
		systemd_doinit hdparm_disableAPM@.service
	fi
	if use git ; then
		systemd_doinit git-daemon@.service
		systemd_doinit git-daemon.service
	fi
	if use iptables ; then
		systemd_doinit iptables.service
		systemd_doinit ip6tables.service
		dosbin "${FILESDIR}"/iptables-stop
	fi
	if use miniupnpd ; then
		systemd_doinit miniupnpd.service
		systemd_dotmpfilesd miniupnpd.conf
	fi
	if use minissdpd ; then
		systemd_doinit minissdpd.service
		systemd_dotmpfilesd minissdpd.conf
	fi
	if use mpd ; then
		systemd_doinit mpd@.service
	fi
	if use flexlm ; then
		systemd_doinit flexlm.service
		dosbin "${FILESDIR}"/flexlm
	fi
	if use rtorrent ; then
		systemd_doinit rtorrent.service
		systemd_doinit rtorrent.path
	fi
	if use screen ; then
		systemd_doinit screen@.service
	fi
	if use zram ; then
		systemd_doinit zram.service
		dosbin "${FILESDIR}"/zram
		dosbin "${FILESDIR}"/zram_statistic
		newconfd "${FILESDIR}"/zram.conf zram
	fi


	if use no_tmp_as_tmpfs ; then
		systemctl mask tmp.mount
	fi

	if use vfio ; then
		systemd_doinit vfio-bind.service
		dosbin "${FILESDIR}"/vfio-bind
		newconfd "${FILESDIR}"/vfio-pci.conf vfio-pci
	fi
	if use touchegg ; then
		systemd_doinit touchegg.service
	fi
}

pkg_postinst() {
	if use cgroups; then
		enewgroup cgroup
		usermod -a -G cgroup portage
	fi
	einfo "Reloading systemd rules."
	systemctl daemon-reload
}
