# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_PN="intel-hybrid-driver"
if [[ ${PV} = *9999* ]] ; then # Live ebuild
	inherit git-r3
	EGIT_REPO_URI="https://github.com/intel/intel-hybrid-driver"
fi

inherit autotools multilib-minimal

DESCRIPTION="HW video decode support for Intel G45 & HD Graphics family"
HOMEPAGE="https://github.com/intel/intel-hybrid-driver"
if [[ ${PV} != *9999* ]] ; then
	SRC_URI="https://github.com/intel/intel-hybrid-driver/releases/download/${PV}/${MY_PN}-${PV}.tar.bz2"
	S="${WORKDIR}/${MY_PN}-${PV}"
	KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
fi

LICENSE="MIT"
SLOT="0"
IUSE="wayland X"
RESTRICT="test" # No tests

RDEPEND="
	>=x11-libs/cmrt-0.10.0[${MULTILIB_USEDEP}]
	>=x11-libs/libdrm-2.4.45[video_cards_intel,${MULTILIB_USEDEP}]
	>=media-libs/libva-1.0.0:=[X?,wayland?,drm,${MULTILIB_USEDEP}]
	wayland? (
		>=dev-libs/wayland-1.11[${MULTILIB_USEDEP}]
		>=media-libs/mesa-9.1.6[${MULTILIB_USEDEP}]
	)
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}/fcommon.patch"
	"${FILESDIR}/libva-2.0.patch"
	"${FILESDIR}/libva-1.0_func_name.patch"
	"${FILESDIR}/vp9hdec_nullfix.patch"
)

src_prepare() {
	default
	eapply_user
	sed -e 's/intel-gen4asm/\0diSaBlEd/g' -i configure.ac || die
	eautoreconf
}

multilib_src_configure() {
	local myconf=(
		$(use_enable wayland)
		$(use_enable X x11)
	)
	ECONF_SOURCE="${S}" econf "${myconf[@]}"
}

multilib_src_install_all() {
	find "${D}" -name "*.la" -delete || die
}
