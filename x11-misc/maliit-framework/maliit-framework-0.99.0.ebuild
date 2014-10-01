# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit qt5-build
DESCRIPTION="A flexible and cross platform input method framework"
HOMEPAGE="http://maliit.org"
SRC_URI="https://github.com/maliit/framework/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="**"
IUSE="+dbus doc examples gtk test"

DEPEND="
	dbus? ( sys-apps/dbus )
	gtk? ( x11-libs/gtk+ )
	dev-qt/qtdeclarative
"

RDEPEND="${DEPEND}"

RESTRICT="test"

DOCS=( README )

S="${WORKDIR}/framework-${PV}"

src_prepare() {
	use !examples && sed -i -e 's:SUBDIRS += examples::' maliit-framework.pro
	qt5-build_src_prepare
}

src_configure() {
	local myconf="nostrip"
	use !dbus && myconf="${myconf} disable-dbus"
	use !doc && myconf="${myconf} nodoc"
	use !gtk && myconf="${myconf} nogtk"
	use !test && myconf="${myconf} notests"
	qmake PREFIX="${EPREFIX}/usr" CONFIG+="${myconf}"
}
