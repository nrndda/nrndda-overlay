# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/nvidia-cuda-sdk/nvidia-cuda-sdk-3.2.ebuild,v 1.2 2010/12/12 14:51:29 spock Exp $

EAPI=2

inherit eutils toolchain-funcs

DESCRIPTION="NVIDIA NPP"
HOMEPAGE="http://developer.nvidia.com/cuda"

NPP_V=${PV//_/-}
DIR_V=${NPP_V//./_}
DIR_V=${DIR_V//beta/Beta}

#SRC_URI="http://developer.download.nvidia.com/compute/cuda/${DIR_V}_prod/toolkit/npp_${NPP_V}.16_linux_64.tar.gz"
SRC_URI="amd64? ( http://developer.download.nvidia.com/compute/cuda/${DIR_V}_prod/toolkit/npp_${NPP_V}_linux_64.tar.gz )
        x86? ( http://developer.download.nvidia.com/compute/cuda/${DIR_V}_prod/toolkit/npp_${NPP_V}_linux_32.tar.gz )"

LICENSE="CUDPP"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=dev-util/nvidia-cuda-toolkit-3.2
	>=x11-drivers/nvidia-drivers-260.19.21"
DEPEND="${RDEPEND}"

S="${WORKDIR}"

RESTRICT="binchecks"

#pkg_setup() {

#}

src_unpack() {
	cd ${S}
	tar -zxf /usr/portage/distfiles/${A}
}

#src_compile() {
#	if ! use examples; then
#		return
#	fi
#	local myopts=""
#
#	if use debug; then
#		myopts="${myopts} dbg=1"
#	fi
#
#	cd "${S}/sdk"
#
#	if use cuda; then
#		cd C
#		emake cuda-install=/opt/cuda ${myopts} || die
#		cd ..
#	fi
#
#	if use opencl; then
#		cd OpenCL
#		emake || die
#		cd ..
#	fi
#}

src_install() {
	cd "${S}/SDK"
#
#	if ! use doc; then
#		rm -rf *.txt doc */doc */Samples.htm */releaseNotesData
#	fi
#
#	if ! use examples; then
#		rm -rf bin */bin */tools
#	fi
#
	for f in $(find .); do
		local t="$(dirname ${f})"
		if [[ "${t/obj\/}" != "${t}" || "${t##*.}" == "a" ]]; then
			continue
		fi

		if [[ ! -d "${f}" ]]; then
			if [[ -x "${f}" ]]; then
				exeinto "/opt/cuda/npp/${t}"
				doexe "${f}"
			else
				insinto "/opt/cuda/npp/${t}"
				doins "${f}"
			fi
		fi
	done
}
