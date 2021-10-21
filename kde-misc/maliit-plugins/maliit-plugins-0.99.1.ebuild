# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

QTMIN=5.14.0
inherit ecm

DESCRIPTION="Maliit plugins collection"
HOMEPAGE="https://maliit.github.io/"
SRC_URI="https://github.com/maliit/plugins/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/plugins-${PV}"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~ppc64 ~x86"
IUSE="docs hunspell +maliit-keyboard +nemo-keyboard"

DEPEND="
	>=kde-misc/maliit-framework-2.1.0
	hunspell? ( app-text/hunspell )
"
RDEPEND="${DEPEND}"

PATCHES=( "${FILESDIR}"/${P}-cmake.patch )

src_configure() {
        local mycmakeargs=(
		-Denable-tests=OFF
		-Denable-docs=$(usex docs)
		-Denable-hunspell=$(usex hunspell)
		-Denable-maliit-keyboard=$(usex maliit-keyboard)
		-Denable-nemo-keyboard=$(usex nemo-keyboard)
        )
	ecm_src_configure
}
