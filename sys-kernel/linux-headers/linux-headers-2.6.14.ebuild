# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-kernel/linux-headers/linux-headers-2.6.27-r2.ebuild,v 1.13 2010/02/21 23:43:50 abcd Exp $

ETYPE="headers"
H_SUPPORTEDARCH="arm"
inherit kernel-2
detect_version
ARCH="arm"

SRC_URI="mirror://gentoo/linux-headers-${PV}.tar.bz2"

KEYWORDS="-* arm"

DEPEND=""
RDEPEND=""

S=${WORKDIR}/gentoo-headers-base-${PV}

src_unpack() {
	unpack ${A}
	cd "${S}"
	[[ -n ${PATCH_VER} ]] && EPATCH_SUFFIX="patch" epatch "${WORKDIR}"/${PV}
	# workaround #244640
	mkdir -p arch/sparc64
	touch arch/sparc64/Makefile
}

src_install() {
	kernel-2_src_install
	cd "${D}"
	egrep -r \
		-e '[[:space:]](asm|volatile|inline)[[:space:](]' \
		-e '\<([us](8|16|32|64))\>' \
		.
	headers___fix $(find -type f)

	# hrm, build system sucks
	find "${D}" '(' -name '.install' -o -name '*.cmd' ')' -print0 | xargs -0 rm -f

	# provided by libdrm (for now?)
#	rm -rf "${D}"/$(kernel_header_destdir)/drm
}

src_test() {
#	emake -j1 ARCH=$(tc-arch-kernel) headers_check || die
	einfo "Maybe broken for this kernel"
}
