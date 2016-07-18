# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

PYTHON_COMPAT=( python{2_7,3_{3,4,5}} )
inherit eutils base python-single-r1 bzr autotools

MY_P="${P:7}"
MY_PN="${PN:7}"

DESCRIPTION="An implementation of the GEIS (Gesture Engine Interface and Support) interface."
SRC_URI=""
EBZR_REPO_URI="http://bazaar.launchpad.net/~oif-team/${MY_PN}/trunk"

HOMEPAGE="https://launchpad.net/geis"
KEYWORDS=""
SLOT="0"
LICENSE="GPL-2 LGPL-3"
IUSE=""
RDEPEND=""
DEPEND="${RDEPEND}
	x11-libs/utouch-grail"

#S="${WORKDIR}/${MY_P}"

src_prepare() {
	cd ${S}
	if use python_targets_python3_5; then
		sed -i 's/python3 >= 3.2/python-3.5/g' configure.ac;
	elif use python_targets_python3_4; then
		sed -i 's/python3 >= 3.2/python-3.4/g' configure.ac;
	elif use python_targets_python3_3; then
		sed -i 's/python3 >= 3.2/python-3.3/g' configure.ac;
	elif use python_targets_python3_2; then
		sed -i 's/python3 >= 3.2/python-3.2/g' configure.ac;
	fi
	eautoreconf || die "failed running autoreconf"
}
