# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit eutils udev git-r3

DESCRIPTION="Library to handle input devices in Wayland"
HOMEPAGE="https://www.freedesktop.org/wiki/Software/libinput/"
EGIT_REPO_URI="git://anongit.freedesktop.org/wayland/libinput"
SRC_URI=""

LICENSE="MIT"
SLOT="0/10"
KEYWORDS=""
IUSE="input_devices_wacom test"
# Tests require write access to udev rules directory which is a no-no for live system.
# Other tests are just about logs, exported symbols and autotest of the test library.
RESTRICT="test"

RDEPEND="
	input_devices_wacom? ( >=dev-libs/libwacom-0.12 )
	>=dev-libs/libevdev-0.4
	>=sys-libs/mtdev-1.1
	virtual/libudev
"
DEPEND="${RDEPEND}
	virtual/pkgconfig"
#	test? (
#		>=dev-libs/check-0.9.10
#		dev-util/valgrind
#		sys-libs/libunwind )

src_prepare() {
	# Doc handling in kinda strange but everything
	# is available in the tarball already.
	sed -e 's/^\(SUBDIRS =.*\)doc\(.*\)$/\1\2/' \
		-i Makefile.am Makefile.in || die
}

src_configure() {
	# gui can be built but will not be installed
	# building documentation silently fails with graphviz syntax errors
	econf \
		--disable-documentation \
		--disable-event-gui \
		$(use_enable input_devices_wacom libwacom) \
		$(use_enable test tests) \
		--with-udev-dir="$(get_udevdir)"
}

src_install() {
	emake install DESTDIR="${D}"
	dodoc -r doc/html
	prune_libtool_files
}
