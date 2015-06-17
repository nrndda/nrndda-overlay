# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit cuda flag-o-matic toolchain-funcs pax-utils

DESCRIPTION="fast password cracker"
HOMEPAGE="http://www.openwall.com/john/"

if [[ ${PV} == "9999" ]] ; then
        EGIT_REPO_URI="https://github.com/magnumripper/JohnTheRipper.git"
        inherit git-2
        SRC_URI=""
        KEYWORDS="**"
        if use minimal; then
                EGIT_BRANCH="master"
        else
                EGIT_BRANCH="bleeding-jumbo"
        fi
else
	inherit versionator
	MY_PN="john"
	MY_PV=$(get_version_component_range 1-3)
	JUMBO_VER="$(get_version_components $(get_version_component_range 4-))"
	MY_P="${MY_PN}-${MY_PV}-jumbo-${JUMBO_VER:1}"
	S="${WORKDIR}/${MY_P}"

        SRC_URI="http://www.openwall.com/john/j/${MY_P}.tar.xz"
        KEYWORDS="~alpha ~amd64 ~arm ~hppa ~mips ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos"
fi

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="**"
IUSE="commoncrypto cuda custom-cflags kerberos -minimal mozilla mpi opencl openmp +openssl pcap rexgen wow"
REQUIRED_USE="openmp? ( !minimal )
	mpi? ( !minimal )
	cuda? ( !minimal )
	opencl? ( !minimal )
	mozilla? ( !minimal )
	^^ ( openssl commoncrypto )"

DEPEND="!minimal? ( >=dev-libs/openssl-1.0.1:0 )
	mpi? ( virtual/mpi )
	cuda? ( x11-drivers/nvidia-drivers
		dev-util/nvidia-cuda-toolkit:= )
	opencl? ( virtual/opencl )
	mozilla? ( dev-libs/nss dev-libs/nspr )
	kerberos? ( virtual/krb5 )
	wow? ( dev-libs/gmp )
	pcap? ( net-libs/libpcap )"
#	commoncrypto? ( )
#	rexgen? ( )
RDEPEND="${DEPEND}"

pkg_setup() {
	if use openmp && [[ ${MERGE_TYPE} != binary ]]; then
		tc-has-openmp || die "Please switch to an openmp compatible compiler"
	fi
}

src_prepare() {
	cd src || die

	if use cuda; then
		cuda_src_prepare
	fi
}

src_configure() {
	cd src || die

	use custom-cflags || strip-flags
	# John ignores CPPFLAGS, use CFLAGS instead
	append-cflags -DJOHN_SYSTEMWIDE=1

	econf \
		--disable-native-macro \
		--disable-native-tests \
		$(use_enable cuda) \
		$(use_enable mpi) \
		$(use_enable opencl) \
		$(use_enable openmp) \
		$(use_enable pcap) \
		$(use_enable rexgen) \
		$(use_with commoncrypto) \
		$(use_with openssl)
}

src_compile() {
	use custom-cflags || strip-flags
	# John ignores CPPFLAGS, use CFLAGS instead
	append-cflags -DJOHN_SYSTEMWIDE=1

	emake -C src
}

src_test() {
	pax-mark -mr run/john
	if use opencl || use cuda; then
		ewarn "GPU tests fail, skipping all tests..."
	else
		make -C src/ check
	fi
}

src_install() {
	# executables
	dosbin run/john
	newsbin run/mailer john-mailer

	pax-mark -mr "${ED}usr/sbin/john" || die

	if ! use minimal; then
		# grep '$(LN)' Makefile.in | head -n-3 | tail -n+2 | cut -d' ' -f3 | cut -d/ -f3
		for s in \
			unshadow unafs undrop unique \
			ssh2john putty2john pfx2john keepass2john keyring2john zip2john gpg2john rar2john racf2john keychain2john kwallet2john pwsafe2john dmg2john hccap2john base64conv truecrypt_volume2john keystore2john
		do
			dosym john /usr/sbin/$s
		done

		insinto /usr/share/john
		doins run/*.py

		if use opencl; then
			insinto /usr/share/john/kernels
			doins run/kernels/*
		fi
	fi

	# config files
	insinto /usr/share/john
	doins run/*.chr run/password.lst
	doins run/*.conf
	doins run/*.chr

	# documentation
	dodoc doc/*
}
