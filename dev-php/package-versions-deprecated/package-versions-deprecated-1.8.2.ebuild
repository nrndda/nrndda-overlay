# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="This utility provides quick and easy access to version information of composer dependencies."
HOMEPAGE="https://github.com/composer/package-versions-deprecated"
SRC_URI="https://github.com/composer/package-versions-deprecated/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="
	dev-lang/php:*
	dev-php/fedora-autoloader"

src_install() {
	insinto /usr/share/php/Composer/package-versions-deprecated
	doins src/*.php "${FILESDIR}/autoload.php"
	dodoc README.md
}
