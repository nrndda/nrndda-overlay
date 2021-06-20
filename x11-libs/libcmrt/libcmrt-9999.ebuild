# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_PN=cmrt
if [[ ${PV} = *9999* ]] ; then # Live ebuild
	inherit git-r3
	EGIT_REPO_URI="https://github.com/intel/${MY_PN}"
fi

inherit autotools multilib-minimal

DESCRIPTION="Media GPU kernel manager for Intel G45 & HD Graphics family"
HOMEPAGE="https://github.com/intel/${MY_PN}"
if [[ ${PV} != *9999* ]] ; then
	SRC_URI="https://github.com/intel/${MY_PN}/archive/refs/tags/${PV}.tar.gz"
	S="${WORKDIR}/${MY_PN}-${PV}"
	KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
fi

LICENSE="MIT"
SLOT="0"
IUSE=""
RESTRICT="test" # No tests

RDEPEND="
	>=x11-libs/libdrm-2.4.52[video_cards_intel,${MULTILIB_USEDEP}]
	>=x11-libs/libva-2.4.0:=[drm,${MULTILIB_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

src_prepare() {
	eapply_user
	eautoreconf
}

multilib_src_configure() {
	ECONF_SOURCE="${S}" econf "${myconf[@]}"
}

multilib_src_install_all() {
	find "${D}" -name "*.la" -delete || die
}
