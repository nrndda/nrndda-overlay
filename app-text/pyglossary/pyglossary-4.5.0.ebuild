# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{9..11} )
DISTUTILS_USE_SETUPTOOLS=rdepend
inherit distutils-r1

DESCRIPTION="A tool for converting dictionary files aka glossaries."
HOMEPAGE="https://github.com/ilius/pyglossary"
SRC_URI="https://github.com/ilius/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="gtk tk"

DEPEND="
	dev-python/beautifulsoup4[${PYTHON_USEDEP}]
	dev-python/lxml[${PYTHON_USEDEP}]
	dev-python/pyyaml[${PYTHON_USEDEP}]
	dev-python/pyicu[${PYTHON_USEDEP}]
	dev-python/html5lib[${PYTHON_USEDEP}]
	dev-python/python-lzo[${PYTHON_USEDEP}]
	dev-python/prompt-toolkit[${PYTHON_USEDEP}]
	dev-libs/marisa[${PYTHON_USEDEP}]
	tk? (
		dev-tcltk/tix
		dev-lang/python[tk]
	)
	gtk? ( dev-python/pygobject[${PYTHON_USEDEP}] )
"
RDEPEND="${DEPEND}"
