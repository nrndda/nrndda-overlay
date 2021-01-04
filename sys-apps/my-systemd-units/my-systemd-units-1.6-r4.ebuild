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
IUSE="+power +noclear cgroups cpupower distccd br0 ssh hostapd inet dhcpcd_firewall_hook hwclock microcode_ctl \
	iptables miniupnpd minissdpd rtorrent screen hdparm \
	no_tmp_as_tmpfs zram +zswap mediatomb ushare flexlm vfio touchegg printer"

DEPEND="sys-apps/systemd
	cgroups? ( dev-libs/libcgroup )
	cpupower? ( sys-power/cpupower )
	distccd? ( sys-devel/distcc )
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
	ssh? ( virtual/ssh )
	hdparm? ( sys-apps/hdparm )
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
	if use noclear; then
		systemd_install_serviced "${FILESDIR}"/noclear.conf getty@tty1.service
	fi

	if use ssh; then
		exeinto /usr/local/sbin/
		doexe "${FILESDIR}"/ssh_login.sh
		exeinto /etc/ssh/
		doexe "${FILESDIR}"/sshrc
		insinto /usr/local/sbin/
		doins "${FILESDIR}"/KDE-Im-Phone-Ring.wav
		doins "${FILESDIR}"/stock_dialog_warning_48.png
	fi

	for i in mediatomb ushare hwclock microcode_ctl cpupower; do
		if use $i; then
			systemd_dounit ${SOURCE_SERVICES_DIR}/$i.service
		fi
	done
	if use printer; then
		systemd_dounit ${SOURCE_SERVICES_DIR}/configure-printer@.service
	fi
	if use power; then
		systemd_dounit ${SOURCE_SERVICES_DIR}/cpufreq_governor@.service
		systemd_dounit ${SOURCE_SERVICES_DIR}/autosuspend_usb@.service
		systemd_dounit ${SOURCE_SERVICES_DIR}/autosuspend_pci@.service
		systemd_dounit ${SOURCE_SERVICES_DIR}/autosuspend_pcie@.service
		systemd_dounit ${SOURCE_SERVICES_DIR}/disable_wifi_powersave@.service
	fi
	if use cgroups; then
		systemd_dounit ${SOURCE_SERVICES_DIR}/cgconfig.service
		systemd_dounit ${SOURCE_SERVICES_DIR}/cgrules.service
	fi

	if use br0; then
		systemd_dounit ${SOURCE_SERVICES_DIR}/br0@.service
		systemd_dounit ${SOURCE_TARGETS_DIR}/br0.target
	fi
	if use distccd ; then
		systemd_dounit ${SOURCE_SERVICES_DIR}/distccd.service
		systemd_dounit ${SOURCE_SERVICES_DIR}/distccd@.service
		systemd_dounit ${SOURCE_SOCKETS_DIR}/distccd.socket
		systemd_dotmpfilesd ${SOURCE_TMPFILES_DIR}/distccd.conf
		systemd_dotmpfilesd ${SOURCE_TMPFILES_DIR}/distccd@.conf
	fi
	if use hostapd ; then
		systemd_dounit ${SOURCE_SERVICES_DIR}/hostapd.service
		systemd_dounit ${SOURCE_SERVICES_DIR}/hostapd@.service
		systemd_dounit ${SOURCE_TARGETS_DIR}/hostapd.target
		systemd_dotmpfilesd ${SOURCE_TMPFILES_DIR}/hostapd.conf
	        exeinto /usr/local/sbin/
	        doexe "${FILESDIR}"/crda_set.sh
	fi
	if use inet ; then
		systemd_dounit ${SOURCE_SERVICES_DIR}/inet@.service
		systemd_dounit ${SOURCE_TARGETS_DIR}/inet.target
		systemd_dounit ${SOURCE_SERVICES_DIR}/ext_lan@.service
		systemd_dounit ${SOURCE_TARGETS_DIR}/ext_lan.target
		systemd_dounit ${SOURCE_SERVICES_DIR}/firewall.service
		systemd_dounit ${SOURCE_SERVICES_DIR}/firewall_inet.service
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
		systemd_dounit ${SOURCE_SERVICES_DIR}/hdparm_disableAPM@.service
	fi
	if use iptables ; then
		systemd_dounit ${SOURCE_SERVICES_DIR}/iptables.service
		systemd_dounit ${SOURCE_SERVICES_DIR}/ip6tables.service
		dosbin "${FILESDIR}"/iptables-stop
	fi
	if use miniupnpd ; then
		systemd_dounit ${SOURCE_SERVICES_DIR}/miniupnpd.service
		systemd_dotmpfilesd ${SOURCE_TMPFILES_DIR}/miniupnpd.conf
	fi
	if use minissdpd ; then
		systemd_dounit ${SOURCE_SERVICES_DIR}/minissdpd.service
		systemd_dotmpfilesd ${SOURCE_TMPFILES_DIR}/minissdpd.conf
	fi
	if use flexlm ; then
		systemd_dounit ${SOURCE_SERVICES_DIR}/flexlm.service
		dosbin "${FILESDIR}"/flexlm
	fi
	if use rtorrent ; then
		systemd_douserunit ${SOURCE_SERVICES_DIR}/rtorrent.service
		systemd_douserunit ${SOURCE_PATH_DIR}/rtorrent.path
	fi
	if use screen ; then
		systemd_douserunit ${SOURCE_SERVICES_DIR}/screen@.service
	fi
	if use zram ; then
		systemd_dounit ${SOURCE_SERVICES_DIR}/zram.service
		dosbin "${FILESDIR}"/zram
		dosbin "${FILESDIR}"/zram_statistic
		newconfd "${FILESDIR}"/zram.conf zram
	fi

	if use zswap ; then
		systemd_dotmpfilesd ${SOURCE_TMPFILES_DIR}/zswap.conf
	fi

	if use no_tmp_as_tmpfs ; then
		systemctl mask tmp.mount
	fi

	if use vfio ; then
		systemd_dounit ${SOURCE_SERVICES_DIR}/vfio-bind.service
		dosbin "${FILESDIR}"/vfio-bind
		newconfd "${FILESDIR}"/vfio-pci.conf vfio-pci
	fi
	if use touchegg ; then
		systemd_douserunit ${SOURCE_SERVICES_DIR}/touchegg.service
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
