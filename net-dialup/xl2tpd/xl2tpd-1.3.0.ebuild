# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-dialup/xl2tpd/xl2tpd-1.2.8.ebuild,v 1.1 2011/07/18 07:33:10 pva Exp $

EAPI="4"

inherit eutils toolchain-funcs

DESCRIPTION="A modern version of the Layer 2 Tunneling Protocol (L2TP) daemon"
HOMEPAGE="http://www.xelerance.com/services/software/xl2tpd/"
SRC_URI="ftp://ftp.xelerance.com/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="dnsretry beeline"

DEPEND="net-libs/libpcap"
RDEPEND="${DEPEND}
	net-dialup/ppp"

src_prepare() {
	use beeline && epatch "${FILESDIR}/${PN}-beeline.patch"
	sed -i Makefile -e 's| -O2 | $(USERCFLAGS) |g' || die "sed Makefile"
	use dnsretry && epatch "${FILESDIR}/${PN}-dnsretry.patch"
}

src_compile() {
	emake CC=$(tc-getCC) USERCFLAGS="${CFLAGS}"
}
src_install() {
	emake PREFIX=/usr DESTDIR="${D}" install

	dodoc CREDITS README.xl2tpd \
		doc/README.patents doc/rfc2661.txt doc/*.sample

	dodir /etc/xl2tpd
	head -n 2 doc/l2tp-secrets.sample > "${ED}/etc/xl2tpd/l2tp-secrets" || die
	fperms 0600 /etc/xl2tpd/l2tp-secrets
	newinitd "${FILESDIR}"/xl2tpd-init xl2tpd

	keepdir /var/run/xl2tpd
}
