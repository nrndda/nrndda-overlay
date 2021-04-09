# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=7

inherit webapp

DESCRIPTION="self hostable application for saving web pages"
HOMEPAGE="https://www.wallabag.org"
SRC_URI="https://github.com/${PN}/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE=""
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="network-sandbox"

DEPEND="dev-lang/php:*[tidy,xmlreader,filter,iconv,curl,sockets]
	dev-php/composer
"
RDEPEND="${DEPEND}"

src_install() {
	webapp_src_preinst

	dodoc CHANGELOG.md COPYING.md CREDITS.md README.md RELEASE_PROCESS.md
	rm -f CHANGELOG.md COPYING.md CREDITS.md README.md RELEASE_PROCESS.md
	rm -f vendor.zip
	webapp_serverowned -R .
	insinto "${MY_HTDOCSDIR}"
	doins -r .

	webapp_src_install
}

pkg_postinst() {
elog "Edit /usr/share/webapps/${PN}/${PV}/htdocs/intranet/serverconfig.php"
elog "Don't forget run "
elog " webapp-config -I -h localhost -d ${PN} ${PN} ${PV}"
}
