# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="8"

inherit systemd tmpfiles

DESCRIPTION="My units for systemd"
HOMEPAGE="http://nrndda.mine.nu"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="power noclear cpupower distcc ssh hostapd hwclock \
	miniupnpd minissdpd screen hdparm \
	no_tmp_as_tmpfs zram zswap vfio"

DEPEND="sys-apps/systemd
	cpupower? ( sys-power/cpupower )
	distcc? ( sys-devel/distcc )
	hostapd? ( net-wireless/hostapd )
	hwclock? ( sys-apps/util-linux )
	miniupnpd? ( net-misc/miniupnpd )
	minissdpd? ( net-misc/minissdpd )
	screen? ( app-misc/screen )
	ssh? ( virtual/ssh )
	hdparm? ( sys-apps/hdparm )
"

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

	for i in hwclock cpupower; do
		if use $i; then
			systemd_dounit ${SOURCE_SERVICES_DIR}/$i.service
		fi
	done
	if use power; then
		systemd_dounit ${SOURCE_SERVICES_DIR}/cpufreq_governor@.service
		systemd_dounit ${SOURCE_SERVICES_DIR}/autosuspend_usb@.service
		systemd_dounit ${SOURCE_SERVICES_DIR}/autosuspend_pci@.service
		systemd_dounit ${SOURCE_SERVICES_DIR}/autosuspend_pcie@.service
		systemd_dounit ${SOURCE_SERVICES_DIR}/disable_wifi_powersave@.service
	fi

	if use distcc ; then
		systemd_dounit ${SOURCE_SERVICES_DIR}/distccd@.service
		systemd_dounit ${SOURCE_SOCKETS_DIR}/distccd.socket
		dotmpfiles ${SOURCE_TMPFILES_DIR}/distccd.conf
	fi
	if use hostapd ; then
		systemd_dounit ${SOURCE_SERVICES_DIR}/hostapd.service
		systemd_dounit ${SOURCE_SERVICES_DIR}/hostapd@.service
		systemd_dounit ${SOURCE_TARGETS_DIR}/hostapd.target
		dotmpfiles ${SOURCE_TMPFILES_DIR}/hostapd.conf
	        exeinto /usr/local/sbin/
	        doexe "${FILESDIR}"/crda_set.sh
	fi
	if use hdparm ; then
		systemd_dounit ${SOURCE_SERVICES_DIR}/hdparm_disableAPM@.service
	fi
	if use miniupnpd ; then
		systemd_dounit ${SOURCE_SERVICES_DIR}/miniupnpd.service
		dotmpfiles ${SOURCE_TMPFILES_DIR}/miniupnpd.conf
	fi
	if use minissdpd ; then
		systemd_dounit ${SOURCE_SERVICES_DIR}/minissdpd.service
		dotmpfiles ${SOURCE_TMPFILES_DIR}/minissdpd.conf
	fi
	if use screen ; then
		#systemd_douserunit ${SOURCE_SERVICES_DIR}/screen.service
		systemd_douserunit ${SOURCE_SERVICES_DIR}/screen@.service
	fi
	if use zram ; then
		systemd_dounit ${SOURCE_SERVICES_DIR}/zram.service
		dosbin "${FILESDIR}"/zram
		dosbin "${FILESDIR}"/zram_statistic
		newconfd "${FILESDIR}"/zram.conf zram
	fi

	if use zswap ; then
		dotmpfiles ${SOURCE_TMPFILES_DIR}/zswap.conf
		dosbin "${FILESDIR}"/zswap
	fi

	if use no_tmp_as_tmpfs ; then
		systemctl mask tmp.mount
	fi

	if use vfio ; then
		systemd_dounit ${SOURCE_SERVICES_DIR}/vfio-bind.service
		dosbin "${FILESDIR}"/vfio-bind
		newconfd "${FILESDIR}"/vfio-pci.conf vfio-pci
	fi
}

pkg_postinst() {
	einfo "Reloading systemd rules."
	systemctl daemon-reload
}
