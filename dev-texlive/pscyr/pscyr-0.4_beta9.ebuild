# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eutils

MY_PN="PSCyr"
MY_P="${MY_PN}-${PV/_/-}"

DESCRIPTION="Type 1 fonts for Cyrillic"
HOMEPAGE="ftp://scon155.phys.msu.su/pub/russian/psfonts/"
SRC_URI="ftp://scon155.phys.msu.su/pub/russian/psfonts/0.4d-beta/${MY_P}-tex.tar.gz
ftp://scon155.phys.msu.su/pub/russian/psfonts/0.4d-beta/${MY_P}-type1.tar.gz"
RESTRICT="mirror"
IUSE=""

LICENSE="LPPL-1.2"
SLOT="0"
KEYWORDS="amd64 x86"
S="${WORKDIR}/${MY_PN}"

src_prepare() {
	epatch "${FILESDIR}/texlive.patch"
}

src_install() {
	dodir /usr/share/texmf-site
	mv fonts tex "${D}"/usr/share/texmf-site
	insinto /usr/share/texmf-site/fonts/enc/dvips/pscyr
	doins dvips/pscyr/{t2a,t2d}.enc
	insinto /usr/share/texmf-site/fonts/map/dvips/pscyr
	doins dvips/pscyr/pscyr.map
	#insinto /etc/texmf/updmap.d
	#newins ${FILESDIR}/updmap.cfg 10pscyr.cfg
}

pkg_postinst() {
	/usr/sbin/texmf-update
	einfo "Don't forget to add:"
	einfo "  Map pscyr.map"
	einfo "to your /usr/share/texmf/web2c/updmap.cfg"
}

pkg_postrm() {
	/usr/sbin/texmf-update
}
