# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: Exp $

EAPI="4"

inherit eutils git-2

DESCRIPTION="Very fast and stable web-server"
HOMEPAGE="http://www.github.com/mamcits/"
EGIT_REPO_URI="git://github.com/mamchits/phantom.git"

LICENSE="LGPL-2.1"
SLOT="0"
IUSE="debug doc"
RDEPEND="dev-libs/openssl"
DEPEND="${RDEPEND}"
KEYWORDS=""

if [ "$ARCH" == "arm" ]; then
	# ARM support not in mainline yet
	EGIT_REPO_URI="git://github.com/kmeaw/phantom.git"
fi

src_prepare() {
	epatch "${FILESDIR}"/stack.patch
}

src_compile() {
	emake -R
}

src_install() {
	OLDIFS="${IFS}"
	IFS=$'\n'
	for I in $(cat debian/phantom{,-ssl}{,-dev}.install); do
		IFS="${OLDIFS}"
		set - ${I}
		if [ "${2}" == "usr/bin" ]; then
			dobin ${1}
		else
			insinto /"${2}"
			doins ${1}
		fi
	done
		IFS="${OLDIFS}"
	if use debug; then
		for I in $(cat debian/phantom-debug{,-dev}.install); do
			IFS="${OLDIFS}"
			set - ${I}
			if [ "${2}" == "usr/bin" ]; then
				dobin ${1}
			else
				insinto /"${2}"
				doins ${1}
			fi
		done
		IFS="${OLDIFS}"
	fi
	use doc && cp -a examples/* AUTHORS COPYING README README.ru "${D}/usr/share/${PN}/"
	newinitd "${FILESDIR}"/phantom.initd phantom
}
