# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-power/upower/upower-0.9.21.ebuild,v 1.1 2013/07/27 09:51:43 ssuominen Exp $

EAPI=6


GIT_ECLASS="git-2"
EXPERIMENTAL="true"
KEYWORDS=""
SRC_URI=""
EGIT_REPO_URI="https://git.lekensteyn.nl/upower.git"

inherit autotools eutils systemd gnome2-utils ${GIT_ECLASS}

DESCRIPTION="D-Bus abstraction for enumerating power devices and querying history and statistics"
HOMEPAGE="http://upower.freedesktop.org/"


LICENSE="GPL-2"
SLOT="0"
IUSE="doc +introspection ios kernel_FreeBSD kernel_linux systemd"

COMMON_DEPEND=">=dev-libs/dbus-glib-0.100
	>=dev-libs/glib-2.22
	sys-apps/dbus
	>=sys-auth/polkit-0.110
	introspection? ( dev-libs/gobject-introspection )
	kernel_linux? (
		virtual/libusb:1
		>=virtual/udev-200[gudev]
		ios? (
			>=app-pda/libimobiledevice-1:=
			>=app-pda/libplist-1:=
			)
		)"
RDEPEND="${COMMON_DEPEND}
	kernel_linux? (
		!systemd? ( >=sys-power/pm-utils-1.4.1 )
		systemd? (
			app-shells/bash
			>=sys-apps/systemd-200
			)
		)"
DEPEND="${COMMON_DEPEND}
	dev-util/gtk-doc-am
	dev-libs/libxslt
	app-text/docbook-xsl-stylesheets
	dev-util/intltool
	virtual/pkgconfig
	doc? (
		dev-util/gtk-doc
		app-text/docbook-xml-dtd:4.1.2
		)"

QA_MULTILIB_PATHS="usr/lib/${PN}/.*"

DOCS="AUTHORS HACKING NEWS README"

src_prepare() {
	if ! use doc; then
		sed -i -e '/gtk-doc.make/d' Makefile.am || die
		sed -i 's/.*gtk-doc.make.*/EXTRA_DIST = /' doc/Makefile.am || die
	fi

        eautoreconf
	sed -i -e '/DISABLE_DEPRECATED/d' configure || die
}

src_configure() {
	local backend myconf

	if use kernel_linux; then
		backend=linux
		myconf="$(use_enable !systemd deprecated)"
	elif use kernel_FreeBSD; then
		backend=freebsd
	else
		backend=dummy
	fi

	econf \
		--libexecdir="${EPREFIX}"/usr/lib/${PN} \
		--localstatedir="${EPREFIX}"/var \
		$(use_enable introspection) \
		--disable-static \
		${myconf} \
		--enable-man-pages \
		$(use_enable doc gtk-doc) \
		--disable-tests \
		--with-html-dir="${EPREFIX}"/usr/share/doc/${PF}/html \
		--with-backend=${backend} \
		$(use_with ios idevice) \
		"$(systemd_with_utildir)" \
		"$(systemd_with_unitdir)"
}

src_install() {
	default
	keepdir /var/lib/upower #383091
	prune_libtool_files
}
