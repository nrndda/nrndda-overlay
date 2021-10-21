# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

QTMIN=5.14.0
inherit qmake-utils

DESCRIPTION="Maliit plugins collection"
HOMEPAGE="https://maliit.github.io/"
SRC_URI="https://github.com/maliit/plugins/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/plugins-${PV}"

LICENSE="LGPL-3.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~ppc64 ~x86"
IUSE="docs hunspell +maliit-keyboard +nemo-keyboard"

DEPEND="
	>=kde-misc/maliit-frameworks-2.1.0
	hunspell? ( app-text/hunspell )
"
RDEPEND="${DEPEND}"

src_configure() {
        local myqmakeargs=(
		PREFIX="${EPREFIX}"/usr
		-Denable-tests=OFF
		-Denable-docs=$(usex docs)
		-Denable-hunspell=$(usex hunspell)
		-Denable-maliit-keyboard=$(usex maliit-keyboard)
		-Denable-nemo-keyboard=$(usex nemo-keyboard)
        )
	eqmake5 "${myqmakeargs[@]}"
}
