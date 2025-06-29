# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit xdg gnome2-utils meson

DESCRIPTION="Fork of Synthesia to GNU/Linux. Synthesia is a software which teaches you to play piano using piano-roll-style falling notes with any MIDI file, available under Windows and Mac."
HOMEPAGE="https://sourceforge.net/projects/linthesia/"

if [[ ${PV} == 9999 ]]; then
        EGIT_REPO_URI="https://github.com/linthesia/linthesia.git"
        inherit git-r3
else
	SRC_URI="https://github.com/linthesia/linthesia/archive/refs/tags/${PV}.tar.gz"
fi

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="fluid"

RDEPEND="
	media-libs/alsa-lib
	dev-db/sqlite
	media-libs/libsdl2
	media-libs/sdl2-ttf
	media-libs/sdl2-image
	dev-cpp/glibmm:2
	fluid? ( media-sound/fluid-soundfont )
"
BDEPEND="dev-util/gtk-update-icon-cache"

DOCS=( README.md )


src_install() {
        meson_src_install
}

pkg_postinst() {
        xdg_pkg_postinst
        gnome2_schemas_update
}

pkg_postrm() {
        xdg_pkg_postrm
        gnome2_schemas_update
}
