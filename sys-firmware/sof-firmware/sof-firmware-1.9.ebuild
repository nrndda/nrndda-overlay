# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Sound Open Firmware (SOF) binary files"

HOMEPAGE="https://www.sofproject.org https://github.com/thesofproject/sof https://github.com/thesofproject/sof-bin"
SRC_URI="https://github.com/thesofproject/sof-bin/releases/download/v${PV}/sof-bin-v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

S=${WORKDIR}/sof-bin-v${PV}

QA_PREBUILT="/usr/bin/sof-logger"

MAJOR_V=$(ver_cut 1-2)
src_install() {
	insinto /lib/firmware/intel/sof
	doins -r sof-v${MAJOR_V}/*
	insinto /lib/firmware/intel/sof-tplg
	doins -r sof-tplg-v${MAJOR_V}/*
	dobin tools-v${MAJOR_V}/*
}
