# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit qt4-r2 git-r3

DESCRIPTION="A graphical user interface for touchégg"
HOMEPAGE="https://github.com/Raffarti/Touchegg-gce"
SRC_URI=""

EGIT_REPO_URI="https://github.com/Raffarti/Touchegg-gce"
EGIT_COMMIT="391c1c3782b7579ff2a9fe6f3db8657c0d9e6876"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	x11-libs/libX11
	dev-qt/qtcore:4
	dev-qt/qtgui:4
	x11-misc/touchegg"
RDEPEND="${DEPEND}"

src_install() {
	dobin "${S}/touchegg-gce"
}
