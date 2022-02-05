# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

QTMIN=5.14.0
inherit ecm

DESCRIPTION="Maliit provides a flexible and cross-platform input method framework"
HOMEPAGE="https://maliit.github.io/"

if [[ ${PV} == 9999 ]]; then
        EGIT_REPO_URI="https://github.com/maliit/framework.git"
        inherit git-r3
else
	SRC_URI="https://github.com/maliit/framework/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
        KEYWORDS="~amd64 ~arm64 ~ppc64 ~x86"
	S="${WORKDIR}/framework-${PV}"
fi

LICENSE="LGPL-2.1+"
SLOT="0"
IUSE="X wayland dbus gtk docs examples"

DEPEND="
	dev-libs/glib
	>=dev-qt/qtgui-${QTMIN}:5
	>=dev-qt/qtdbus-${QTMIN}:5
	>=dev-qt/qtwidgets-${QTMIN}:5
	wayland? (
		dev-libs/wayland-protocols
		dev-util/wayland-scanner
		dev-qt/qtwayland
		x11-libs/libxkbcommon
		gtk? ( x11-libs/gtk+:3 )
	)
"
RDEPEND="${DEPEND}
        >=dev-qt/qtquickcontrols-${QTMIN}:5
        >=dev-qt/qtquickcontrols2-${QTMIN}:5
"

src_configure() {
        local mycmakeargs=(
		-Denable-tests=OFF
		-Denable-docs=$(usex docs)
		-Denable-examples=$(usex examples)
		-Denable-dbus-activation=$(usex dbus)
		-Denable-xcb=$(usex X)
		-Denable-wayland=$(usex wayland)
		-Denable-wayland-gtk=$(usex gtk)
        )
        ecm_src_configure
}
