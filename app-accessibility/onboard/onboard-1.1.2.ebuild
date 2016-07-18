EAPI="5"

PYTHON_COMPAT=( python3_{3,4,5} )

inherit distutils-r1 gnome2-utils versionator

DESCRIPTION="Simple on-screen Keyboard with macros and easy layout creation"
HOMEPAGE="https://launchpad.net/onboard"
SRC_URI="http://launchpad.net/${PN}/$(get_version_component_range 1-2)/${PV}/+download/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	app-accessibility/at-spi2-core

	app-text/iso-codes

	dev-libs/glib:2
	dev-libs/libappindicator

	dev-python/dbus-python
	dev-python/pycairo
	dev-python/pygobject:3[${PYTHON_USEDEP}]
	dev-python/python-distutils-extra[${PYTHON_USEDEP}]

	gnome-base/dconf

	gnome-extra/mousetweaks

	media-libs/libcanberra

	x11-libs/cairo[svg]
	x11-libs/gdk-pixbuf
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libXi
	x11-libs/libxkbfile
	x11-libs/pango"

src_prepare() {
	distutils-r1_src_prepare
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
