# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-crypt/johntheripper/johntheripper-1.7.9-r2.ebuild,v 1.1 2012/04/08 05:19:03 radhermit Exp $

EAPI="4"

inherit eutils flag-o-matic toolchain-funcs pax-utils

MY_PN="john"
MY_P="${MY_PN}-${PV}"

JUMBO="jumbo-5"

DESCRIPTION="fast password cracker"
HOMEPAGE="http://www.openwall.com/john/"

SRC_URI="http://www.openwall.com/john/g/${MY_P}.tar.bz2
	!minimal? ( http://www.openwall.com/john/g/${MY_P}-${JUMBO}.diff.gz )"

LICENSE="GPL-2"
SLOT="0"
# This package can't be marked stable for ppc or ppc64 before bug 327211 is closed.
KEYWORDS="~alpha ~amd64 ~hppa ~mips ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos"
#Remove AltiVec USE flag. Appears to be an upstream issue.
IUSE="custom-cflags -minimal mmx mpi openmp sse2 opencl cuda"
REQUIRED_USE="openmp? ( !minimal )
	mpi? ( !minimal )
	cuda? ( !opencl )
	opencl? ( !cuda )"

RDEPEND="!minimal? ( >=dev-libs/openssl-0.9.7:0 )
	mpi? ( virtual/mpi )
	cuda? ( dev-util/nvidia-cuda-sdk )
	opencl? ( dev-util/nvidia-cuda-sdk[opencl] )"
DEPEND="${RDEPEND}"

S="${WORKDIR}/${MY_P}"

has_xop() {
	echo | $(tc-getCC) ${CFLAGS} -E -dM - | grep -q "#define __XOP__ 1"
}

has_avx() {
	echo | $(tc-getCC) ${CFLAGS} -E -dM - | grep -q "#define __AVX__ 1"
}

get_target() {
	if use alpha; then
		echo "linux-alpha"
	elif use amd64; then
		if use cuda; then
			echo "linux-x86-64-cuda"
		elif use opencl; then
			echo "linux-x86-64-opencl"
		elif has_xop; then
			echo "linux-x86-64-xop"
		elif has_avx; then
			echo "linux-x86-64-avx"
		else
			echo "linux-x86-64"
		fi
	elif use ppc; then
		#if use altivec; then
		#	echo "linux-ppc32-altivec"
		#else
			echo "linux-ppc32"
		#fi
	elif use ppc64; then
		#if use altivec; then
		#	echo "linux-ppc32-altivec"
		#else
			echo "linux-ppc64"
		#fi
		# linux-ppc64-altivec is slightly slower than linux-ppc32-altivec for most hash types.
		# as per the Makefile comments
	elif use sparc; then
		echo "linux-sparc"
	elif use x86; then
		if use cuda; then
			echo "linux-x86-cuda"
		elif use opencl; then
			echo "linux-x86-opencl"
		elif has_xop; then
			echo "linux-x86-xop"
		elif has_avx; then
			echo "linux-x86-avx"
		elif use sse2; then
			echo "linux-x86-sse2"
		elif use mmx; then
			echo "linux-x86-mmx"
		else
			echo "linux-x86-any"
		fi
	elif use ppc-macos; then
	# force AltiVec, the non-altivec profile contains ancient compiler cruft
	#	if use altivec; then
			echo "macosx-ppc32-altivec"
	#	else
	#		echo "macosx-ppc32"
	#	fi
		# for Tiger this can be macosx-ppc64
	elif use x86-macos; then
		if use sse2; then
			echo "macosx-x86-sse2"
		else
			echo "macosx-x86"
		fi
	elif use x86-solaris; then
		echo "solaris-x86-any"
	elif use x86-fbsd; then
		if use sse2; then
			echo "freebsd-x86-sse2"
		elif use mmx; then
			echo "freebsd-x86-mmx"
		else
			echo "freebsd-x86-any"
		fi
	elif use amd64-fbsd; then
		echo "freebsd-x86-64"
	else
		echo "generic"
	fi
}

pkg_setup() {
	if use openmp ; then
		tc-has-openmp || die "Please switch to an openmp compatible compiler"
	fi
}

src_prepare() {
	if ! use minimal; then
		epatch "${WORKDIR}/${MY_P}-${JUMBO}.diff"

		if use mpi ; then
			sed -e "s/^#CC = mpicc/CC = mpicc/" \
				-e "s/^#MPIOBJ =/MPIOBJ =/" \
				-i src/Makefile || die
		fi

		# fix typo in jumbo patch
		sed -i 's:All15:All5:' run/john.conf || die
	fi

	local PATCHLIST="1.7.6-cflags 1.7.3.1-mkdir-sandbox"
	use cuda && PATCHLIST="${PATCHLIST} cuda"
	use opencl && PATCHLIST="${PATCHLIST} opencl"

	cd src
	for p in ${PATCHLIST}; do
		epatch "${FILESDIR}/${PN}-${p}.patch"
	done

	if ! use minimal; then
		epatch "${FILESDIR}/${P}-jumbo-5-NT-performance-02.patch"

		sed -e "s/LDFLAGS  *=  */override LDFLAGS += /" -e "/LDFLAGS/s/-s//" \
			-e "/LDFLAGS/s/-L[^ ]*//g" -e "/CFLAGS/s/-[IL][^ ]*//g" \
			-i Makefile || die "sed Makefile failed"
		if use cuda; then
			sed -e 's#/usr/local/cuda#/opt/cuda#g;s#arch sm_10#arch sm_20#g' -i Makefile
			epatch "${FILESDIR}/${PN}-cuda-2.patch"
		elif use opencl; then
			sed -e 's#DCL_VERSION_1_0#DCL_VERSION_1_0 -I/opt/cuda/sdk/OpenCL/common/inc#g' -i Makefile
			sed -e 's#lOpenCL#lOpenCL -L/opt/cuda/sdk/OpenCL/common/lib#g' -i Makefile
		fi
	fi
}

src_compile() {
	local OMP

	use custom-cflags || strip-flags
	echo "#define JOHN_SYSTEMWIDE 1" >> config.gentoo
	echo "#define JOHN_SYSTEMWIDE_HOME \"${EPREFIX}/etc/john\"" >> config.gentoo
	echo "#define JOHN_SYSTEMWIDE_EXEC \"${EPREFIX}/usr/libexec/john\"" >> config.gentoo
	append-flags -fPIC -fPIE
	gcc-specs-pie && append-ldflags -nopie
	use openmp && OMP="-fopenmp"

	CPP="$(tc-getCXX)" CC="$(tc-getCC)" AS="$(tc-getCC)" LD="$(tc-getCC)"
	use mpi && CPP=mpicxx CC=mpicc AS=mpicc LD=mpicc

	emake -C src/ \
		CPP="${CPP}" CC="${CC}" AS="${AS}" LD="${LD}" \
		CFLAGS="-c -Wall -include \\\"${S}\\\"/config.gentoo ${CFLAGS} ${OMP}" \
		LDFLAGS="${LDFLAGS}" \
		OPT_NORMAL="" \
		OMPFLAGS="${OMP}" \
		$(get_target)
}

src_test() {
	cd run
	if [[ -f "${EPREFIX}/etc/john/john.conf" || -f "${EPREFIX}/etc/john/john.ini" ]] ; then
		# This requires that MPI is actually 100% online on your system, which might not
		# be the case, depending on which MPI implementation you are using.
		#if use mpi; then
		#	mpirun -np 2 ./john --test || die "self test failed"
		#else

		./john --test || die 'self test failed'
	else
		ewarn "Tests require '${EPREFIX}/etc/john/john.conf' or '${EPREFIX}/etc/john/john.ini'"
	fi
}

src_install() {
	# executables
	dosbin run/john
	newsbin run/mailer john-mailer

	pax-mark -m "${ED}usr/sbin/john" || die

	dosym john /usr/sbin/unafs
	dosym john /usr/sbin/unique
	dosym john /usr/sbin/unshadow

	# jumbo-patch additions
	if ! use minimal; then
		dosym john /usr/sbin/undrop
		dosbin run/calc_stat
		dosbin run/genmkvpwd
		dosbin run/mkvcalcproba
		dosbin run/tgtsnarf
		insinto /etc/john
		doins run/genincstats.rb run/stats
		doins run/netscreen.py run/sap_prepare.pl
	fi

	# config files
	insinto /etc/john
	doins run/*.chr run/password.lst
	doins run/*.conf

	# documentation
	dodoc doc/*
}