# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libyui-qt/libyui-qt-2.44.0.ebuild,v 1.1 2014/09/23 17:14:47 pinkbyte Exp $

EAPI=5

inherit cmake-utils

DESCRIPTION="A QML plugin that provides elements for receiving gesture events."
HOMEPAGE="https://launchpad.net/oif-qml"
SRC_URI="https://launchpad.net/${PN}/trunk/${PV}/+download/${P}.tar.gz"

RESTRICT="mirror"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="
	dev-qt/qtgui:4
	x11-libs/utouch-geis
"
#S="${WORKDIR}/${PN}-${PN}-master-${PV}"
