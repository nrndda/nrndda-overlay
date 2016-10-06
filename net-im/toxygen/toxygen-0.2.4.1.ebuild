# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
PYTHON_COMPAT=( python{3_2,3_3,3_4} )

inherit distutils-r1 eutils

DESCRIPTION="Python Tox client"
HOMEPAGE="https://github.com/toxygen-project/toxygen"
SRC_URI="https://github.com/toxygen-project/toxygen/archive/v${PV}.tar.gz -> ${P}.tar.gz"

RESTRICT="mirror"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
IUSE="qt4"

RDEPEND="qt4? ( dev-python/PyQt4[${PYTHON_USEDEP}] )
	!qt4? ( dev-python/pyside[${PYTHON_USEDEP}] )
	dev-python/pyaudio[${PYTHON_USEDEP}]
	media-libs/portaudio
	net-libs/tox[av]"
DEPEND="${RDEPEND}"

#S=${WORKDIR}/${MY_P}

