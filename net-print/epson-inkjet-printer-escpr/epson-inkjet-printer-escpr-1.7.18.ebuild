# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Epson Inkjet Printer Driver (ESC/P-R)"
HOMEPAGE="https://download.ebz.epson.net/dsc/search/01/search/?OSC=LX https://download.ebz.epson.net/dsc/du/02/DriverDownloadInfo.do?LG2=EN&CN2=&DSCMI=134381&DSCCHK=9edfca27f0a940d9e3f3156a3d46047ffbfe6d79"
SRC_URI="https://download3.ebz.epson.net/dsc/f/03/00/13/43/81/cbdd80826424935cef20d16be8ee5851388977a7/epson-inkjet-printer-escpr-1.7.18-1lsb3.2.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ~ppc64"

DEPEND="net-print/cups"
RDEPEND="${DEPEND}"

PATCHES=(
	"${FILESDIR}/1.6.5-warnings.patch"
	"${FILESDIR}/${PN}-1.7.7-fnocommon.patch"
)

src_configure() {
	econf --disable-shared

	# Makefile calls ls to generate a file list which is included in Makefile.am
	# Set the collation to C to avoid automake being called automatically
	unset LC_ALL
	export LC_COLLATE=C
}

src_install() {
	emake -C ppd DESTDIR="${D}" install
	emake -C src DESTDIR="${D}" install
	einstalldocs
}
