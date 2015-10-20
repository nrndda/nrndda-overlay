# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils multilib games git-r3

EGIT_REPO_URI="https://bitbucket.org/gennady/ja2-stracciatella.git"

DESCRIPTION="An enhanced port of Jagged Alliance 2 to SDL"
HOMEPAGE="https://bitbucket.org/gennady/ja2-stracciatella/overview"
SRC_URI=""

LICENSE="SFI"
SLOT="0"

KEYWORDS=""
IUSE="linguas_nl linguas_en linguas_fr linguas_de linguas_it linguas_pl
linguas_ru linguas_ru_gold"

RDEPEND="sys-libs/zlib
	media-libs/libsdl"
DEPEND="${RDEPEND}"

SGPDATADIR="${GAMES_PREFIX_OPT}/${PN}"

pkg_setup() {
	games_pkg_setup

	langcount=0
	for i in ${LINGUAS}
	do
		let $((++langcount))
		if [[ $langcount = 2 ]]
		then
			eerror "${PN} only supports one localization at once!"
			die "Localization is only supported when ${PN} is in a single language!"
		fi

		case ${i} in
			nl) LNG=DUTCH;;
			fr) LNG=FRENCH;;
			de) LNG=GERMAN;;
			it) LNG=ITALIAN;;
			pl) LNG=POLISH;;
			ru) LNG=RUSSIAN;;
			ru_gold) LNG=RUSSIAN_GOLD;;
			*) LNG=ENGLISH;;
		esac
	done
}

src_configure() {
	econf --prefix=${D}
}

src_compile() {
	use amd64 && multilib_toolchain_setup x86

	emake LNG=${LNG} WITH_ZLIB=1 || die "emake"
}

pkg_postinst() {
	elog "Edit configuration file and set parameter data_dir to point on the directory where the original game files was installed."
	elog "The configuration file is: ~/.ja2/ja2.ini"
}

