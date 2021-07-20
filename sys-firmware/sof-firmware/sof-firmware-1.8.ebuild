# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Sound Open Firmware (SOF) binary files"

MAJOR_V=$(ver_cut 1-2)

HOMEPAGE="https://www.sofproject.org https://github.com/thesofproject/sof https://github.com/thesofproject/sof-bin"
SRC_URI="https://github.com/thesofproject/sof-bin/releases/download/v${MAJOR_V}/sof-bin-v${PV}.tar.gz"

S=${WORKDIR}/sof-bin-v${PV}

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

src_install() {
	insinto /lib/firmware/intel/sof
	doins -r sof-v${MAJOR_V}/*
	insinto /lib/firmware/intel/sof-tplg
	doins -r sof-tplg-v${MAJOR_V}/*
	dobin tools-v${MAJOR_V}/*
}
