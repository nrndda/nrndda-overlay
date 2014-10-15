# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/gst-plugins-vaapi/gst-plugins-vaapi-0.5.8-r1.ebuild,v 1.5 2014/07/26 09:00:41 ssuominen Exp $

EAPI="5"
inherit eutils multilib-minimal

MY_PN="gstreamer-vaapi"
DESCRIPTION="Hardware accelerated video decoding through VA-API plugin"
HOMEPAGE="http://gitorious.org/vaapi/gstreamer-vaapi"
SRC_URI="http://www.freedesktop.org/software/vaapi/releases/${MY_PN}/${MY_PN}-${PV}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="1.0"
KEYWORDS="**"
IUSE="+X opengl wayland +system-libvpx"

RDEPEND="
	>=dev-libs/glib-2.34.3:2[${MULTILIB_USEDEP}]
	>=media-libs/gstreamer-1.2.3:1.0[${MULTILIB_USEDEP}]
	>=media-libs/gst-plugins-base-1.2.3:1.0[${MULTILIB_USEDEP}]
	>=media-libs/gst-plugins-bad-1.2.3:1.0[${MULTILIB_USEDEP}]
	>=x11-libs/libdrm-2.4.46[${MULTILIB_USEDEP}]
	>=x11-libs/libX11-1.6.2[${MULTILIB_USEDEP}]
	>=x11-libs/libXrandr-1.4.2[${MULTILIB_USEDEP}]
	>=x11-libs/libva-1.2.1-r1[X?,opengl?,wayland?,${MULTILIB_USEDEP}]
	>=virtual/opengl-7.0-r1[${MULTILIB_USEDEP}]
	>=virtual/libudev-208:=[${MULTILIB_USEDEP}]
	wayland? ( >=dev-libs/wayland-1.0.6[${MULTILIB_USEDEP}] )
	system-libvpx? ( media-libs/libvpx )
"
DEPEND="${RDEPEND}
	>=dev-util/gtk-doc-am-1.12
	>=virtual/pkgconfig-0-r1[${MULTILIB_USEDEP}]"

S="${WORKDIR}/${MY_PN}-${PV}"

multilib_src_configure() {
	myconf=""
	if use system-libvpx; then
		myconf+="--disable-builtin-libvpx"
	fi
	ECONF_SOURCE=${S} \
	econf \
		--with-gstreamer-api=1.2 \
		--disable-static \
		--enable-drm \
		$(use_enable opengl glx) \
		$(use_enable wayland) \
		$(use_enable X x11) \
		${myconf}
}

multilib_src_install_all() {
	einstalldocs
	prune_libtool_files --modules
}