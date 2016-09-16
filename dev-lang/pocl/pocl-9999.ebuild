# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit cmake-multilibs git-r3

DESCRIPTION="PortableCL: opensource implementation of the OpenCL standard"
HOMEPAGE="http://portablecl.org/"
SRC_URI=""
EGIT_REPO_URI="https://github.com/pocl/pocl.git"

SLOT="0"
LICENSE="MIT"
KEYWORDS=""
IUSE=""

RDEPEND="dev-libs/ocl-icd
	>=sys-devel/llvm-3.7[clang]
	sys-apps/hwloc
	>=app-eselect/eselect-opencl-1.1.0-r4"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

pkg_pretend() {
	# Needs an OpenCL 1.2 ICD, mesa and nvidia are invalid
	# Maybe ati works, feel free to add/fix if you can test
	if [[ $(eselect opencl show) == 'ocl-icd' ]]; then
		einfo "Valid OpenCL ICD set"
	else
		eerror "Please use a supported ICD:"
		eerror "eselect opencl set ocl-icd"
		die "OpenCL ICD not set to a supported value"
	fi
}
