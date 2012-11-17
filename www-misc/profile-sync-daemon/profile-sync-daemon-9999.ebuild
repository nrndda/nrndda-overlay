# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-misc/profile-sync-daemon/profile-sync-daemon-4.02.ebuild,v 1.1 2012/10/29 18:53:30 hasufell Exp $

EAPI=4

inherit eutils vcs-snapshot

DESCRIPTION="Symlinks and syncs browser profile dirs to RAM. ORIGINAL. With systemd service file."
HOMEPAGE="https://wiki.archlinux.org/index.php/Profile-sync-daemon"
SRC_URI="https://github.com/graysky2/${PN}/archive/master.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2 GPL-3"
SLOT="0"
KEYWORDS=""
IUSE="cron"

RDEPEND="
	app-shells/bash
	net-misc/rsync
	cron? ( virtual/cron )"

src_preapre() {
	sed -i 's/ /etc/psd.conf/ /etc/conf.d/psd/' "${S}"/*
}

src_install() {
#	emake DESTDIR="${D}" $(usex cron "install" "install-bin install-doc install-man")
	dobin profile-sync-daemon || die "dobin failed"
	
	insinto /usr/lib/systemd/system
	doins psd.service || die "doins .service failed"
	
	insinto /etc/conf.d
	doins psd.conf || die "doins .conf failed"

	insinto /etc/cron.hourly
	newins psd.cron.hourly psd-update || die "newins failed"

	dodoc CHANGELOG || die "dodoc failed"
	newdoc README-for_other_distros README || die "newdoc failed"
	newman psd.manpage psd.1 || die "newman failed"
	dosym psd.1 profile-sync-daemon.1 || die "dosym failed"
}

pkg_postinst() {
	eerror "IMPORTANT NOTICE!"
	elog "Usage of the \"mozilla\" variable in the BROWSERS array is"
	elog "deprecated starting with profile-sync-daemon v4.02."
	elog "It has been replaced with the \"firefox\" variable."
	elog
	elog "In order to safely upgrade, you must run an unsync to"
	elog "rotate your firefox profile back to disk using verion 3.x"
	elog
	elog "As usual, watch for any changes in the newly provided"
	elog "/etc/conf.d/psd as well and be sure to incorporate them."
}
