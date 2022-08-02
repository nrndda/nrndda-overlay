# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit eutils cmake flag-o-matic

if [[ ${PV} == "9999" ]]; then
  inherit git-r3
  EGIT_REPO_URI="https://github.com/vcmi/vcmi.git"
else
  KEYWORDS="~amd64 ~x86"
  SRC_URI="https://github.com/${PN}/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
fi

DESCRIPTION="Heroes of Might and Magic III game engine"
HOMEPAGE="https://vcmi.eu"

LICENSE="GPL-2"
SLOT="0"

IUSE="debug pch editor erm +launcher"

REQUIRED_USE="
  pch? ( debug )
"

DEPEND="
  dev-lang/luajit
  dev-cpp/tbb
  >=dev-libs/boost-1.48
  media-libs/libsdl2[video]
  media-libs/sdl2-image
  media-libs/sdl2-mixer
  media-libs/sdl2-ttf
  sys-libs/zlib[minizip]
  media-video/ffmpeg

  editor? (
    dev-qt/qtwidgets:5
  )
  launcher? (
    dev-qt/qtnetwork:5
    dev-qt/qtwidgets:5
  )
"

PDEPEND="
  games-strategy/vcmi-data
"

src_configure() {
  if [[ ${PV} == "9999" ]]; then
    local gitversion="-DENABLE_GITVERSION=ON"
  else
    local gitversion="-DENABLE_GITVERSION=OFF"
  fi

  local mycmakeargs=(
    #-DLIB_DIR="${EPREFIX}"/usr/$(get_libdir)/${PN}
    -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=ON
    -DCMAKE_INSTALL_RPATH="${EPREFIX}"/usr/$(get_libdir)/${PN}
    -DENABLE_TEST=OFF
    -DFORCE_BUNDLED_FL=OFF
    -DENABLE_PCH=$(usex pch)
    -DENABLE_ERM=$(usex erm)
    -DENABLE_EDITOR=$(usex editor)
    -DENABLE_LAUNCHER=$(usex launcher)
    $gitversion
  )

  export CCACHE_SLOPPINESS="time_macros"

  cmake-utils_src_configure

  if ! use debug; then
    filter-flags -DNDEBUG
    strip-flags
  fi
}

#src_install() {
#  cmake-utils_src_install
#
#  dodir /etc/ld.so.conf.d/
#  echo "${EPREFIX}/usr/$(get_libdir)/${PN}" > ${ED}/etc/ld.so.conf.d/10-${PN}.conf || die
#}

pkg_postinst() {
  einfo "To start check out https://wiki.vcmi.eu/Installation_on_Linux#Automated_install"
  einfo "Howto:"
  einfo " - add 'Data', 'Maps', 'Mp3' to ~/.local/share/vcmi"

  elog "In order to play VCMI you must install:"
  elog "- Heroes III: Shadow of Death or Complete edition;"
  elog "- Unnoficial WoG addon;"
  elog "- VCMI data files."
  elog "Use vcmibuilder tool for automated install of data files;"
  elog "Additional information can be found in VCMI wiki:"
  elog "http://wiki.vcmi.eu/index.php?title=Installation_on_Linux#Installing_Heroes_III_data_files"
}
