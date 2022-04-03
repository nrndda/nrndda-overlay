# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit meson git-r3

DESCRIPTION="IIO accelerometer sensor to input device proxy"
HOMEPAGE="https://gitlab.freedesktop.org/hadess/iio-sensor-proxy"
EGIT_REPO_URI="https://gitlab.freedesktop.org/hadess/iio-sensor-proxy"


LICENSE="Unlicense"
# Unknown. There is no info about the license ATM.
SLOT="0"
KEYWORDS=""
IUSE=""

BDEPEND="
	dev-python/psutil
	dev-libs/libxml2
"

RDEPEND="
	sys-apps/systemd
	sys-apps/dbus
	sys-auth/polkit
	dev-libs/libgudev
	app-misc/geoclue:*
"

DOCS=( README.md )

src_configure() {
	local emesonargs=(
		-Dgtk-tests=false
		-Dgtk_doc=false
	)
	meson_src_configure
}
