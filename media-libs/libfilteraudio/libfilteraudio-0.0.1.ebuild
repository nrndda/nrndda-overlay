# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libkface/libkface-4.7.0.ebuild,v 1.1 2014/12/20 22:08:42 dilfridge Exp $

EAPI=6

inherit eutils

MY_P="filter_audio"
SRC_URI="https://github.com/irungentoo/filter_audio/archive/v${PV}.tar.gz"

DESCRIPTION="Lightweight audio filtering library made from webrtc code."
HOMEPAGE="https://github.com/irungentoo/filter_audio"

LICENSE="BSD"
KEYWORDS="~amd64 ~x86"
IUSE=""
SLOT="0"

S=${WORKDIR}/${MY_P}-${PV}/
