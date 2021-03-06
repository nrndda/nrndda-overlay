# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-wireless/wireless-regdb/wireless-regdb-20130213.ebuild,v 1.7 2013/03/31 10:25:34 ago Exp $

EAPI=6

MY_P="wireless-regdb-${PV:0:4}.${PV:4:2}.${PV:6:2}"
DESCRIPTION="Binary regulatory database for CRDA"
HOMEPAGE="http://wireless.kernel.org/en/developers/Regulatory"
SRC_URI="https://www.kernel.org/pub/software/network/${PN}/${MY_P}.tar.xz"

LICENSE="ISC"
SLOT="0"
KEYWORDS="**"
IUSE=""

S="${WORKDIR}/${MY_P}"

src_compile() {
	einfo "Recompiling regulatory.bin from db.txt would break CRDA verify. Installing unmodified binary version."
}

src_install() {
	# This file is not ABI-specific, and crda itself always hardcodes
	# this path.  So install into a common location for all ABIs to use.
	insinto /usr/lib/crda
	doins "${FILESDIR}"/regulatory.bin

	insinto /etc/wireless-regdb/pubkeys
	#doins linville.key.pub.pem
	doins "${FILESDIR}"/nrndda.key.pub.pem

	doman regulatory.bin.5
	dodoc README db.txt
}
