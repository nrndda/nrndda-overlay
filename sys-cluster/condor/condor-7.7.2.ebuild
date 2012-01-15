# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit eutils flag-o-matic cmake-utils

DESCRIPTION="Workload management system for compute-intensive jobs"
HOMEPAGE="http://www.cs.wisc.edu/condor/"
SRC_URI="${PN}_src-${PV}-all-all.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="backfill boinc +cgroup classads +doc drmaa examples gcb globus kbdd kerberos postgres +libvirt soap ssl"

CDEPEND="sys-libs/zlib
	libvirt? ( app-emulation/libvirt )
	dev-libs/libpcre
	cgroup? ( dev-libs/libcgroup )
	classads? ( sys-cluster/classads[pcre] )
	gcb? ( net-firewall/gcb )
	kerberos? ( app-crypt/mit-krb5 )
	kbdd? ( x11-libs/libX11 )
	postgres? ( dev-db/postgresql-base )
	soap? ( net-libs/gsoap )
	ssl? ( dev-libs/openssl )"

RDEPEND="${CDEPEND}
	mail-client/mailx"

DEPEND="${CDEPEND}"

RESTRICT=fetch

S="${WORKDIR}/${P}"

#CMAKE_IN_SOURCE_BUILD=yes
#CMAKE_VERBOSE=yes

# yet to find a way to parallelize compilation
MAKEOPTS="-j1"

pkg_setup() {
	enewgroup condor
	enewuser condor -1 "${ROOT}"bin/bash "${ROOT}var/lib/condor" condor
}

src_prepare() {
	# these two eauto* are to replicate the build_init script
	# not so sure they are really needed
	# eautoheader
	# eautoconf
	#./configure_uw
	# this patch is mostly to use standard fhs
	cd src/condor_examples
	epatch ./condor_config.generic.rpm.patch
	# the base local file is in /etc, then the condor local file is updated and should reside in /var/lib
	sed -i \
		-e 's:\(LOCAL_CONFIG_FILE.*=\).*:\1 /var/lib/condor/condor_config.local:' \
		condor_config.generic || die
}

src_configure() {
        # condor seems to be buggy with -O2 and above with gcc
        #filter-flags "-O[s2-9]" "-O1"

	local mycmakeargs=(
        	-DPROPER=ON
		-DCLIPPED=OFF
		-DUW_BUILD=OFF 
		-DBUILD_TESTS=OFF
		-DENABLE_JAVA_TESTS=OFF
		$(cmake-utils_use_with libvirt LIBVIRT)
		$(cmake-utils_use_with globus GLOBUS)
		$(cmake-utils_use_with backfill BACKFILL)
		$(cmake-utils_use_with boinc BOINC)
		$(cmake-utils_use_want doc MAN_PAGES)
		$(cmake-utils_use_with ssl OPENSSL)
		$(cmake-utils_use_has ssl SSH_TO_JOB)
		$(cmake-utils_use gcb)
		$(cmake-utils_use drmaa)
		$(cmake-utils_use_want postgres CONTRIB)
		$(cmake-utils_use classads)
		$(cmake-utils_use_has kbdd KBDD)
		$(cmake-utils_use_with kerberos KRB5) 
		$(cmake-utils_use_with soap GSOAP)
	)	

	#cmake -DWITH_GLOBUS=OFF -DWITH_KRB5=OFF -DWITH_GSOAP=OFF .
	cmake-utils_src_configure
}

src_install() {
	emake release manpages || die "emake release failed"
	if use static-libs; then
		emake static || die "emake static failed"
	fi

	cd release_dir
	## remove a shitload of useless stuff to sync with the rpm package
	## comments are from the rpm fedora spec file
	# used by old MPI universe, not packaged (it's rsh, it should die)
	rm -rf libexec/rsh
	# this is distributed as chirp_client.c/h and chirp_protocol.h
	rm lib/libchirp_client.a include/chirp_client.h
	# checkpoint, reschedule and vacate live in bin/, don't duplicate
	rm sbin/condor_{checkpoint,reschedule,vacate}
	# sbin/condor is a pointless hard links
	rm sbin/condor

	# binaries
	dosbin sbin/* || die
	dobin bin/* || die
	# headers
	insinto /usr
	doins -r include || die
	# libs
	dolib.so lib/*so || die
	use static-libs && dolib.a lib/*a
	insinto /usr/libexec/condor
	doins -r libexec/* || die

	# data files
	insinto /usr/share/${PN}
	doins lib/*.jar lib/*.class lib/*.pm || die
	use postgres && doins -r sql

	# examples
	if use examples; then
		insinto /usr/share/doc/${PF}
		doins -r etc/examples || die
	fi

	# config files
	insinto /etc/condor
	newins etc/examples/condor_config.generic condor_config || die
	newins etc/examples/condor_config.local.generic condor_config.local || die
	insinto /var/lib/condor/
	newins etc/examples/condor_config.local.generic

	dodir /var/log/condor
	dodir /var/run/condor
	dodir /var/lock/condor

	fperms 750 /var/lib/condor /var/log/condor
	fperms 755 /var/run/condor
	fperms 0775 /var/lock/condor
	fowners condor:condor /var/lib/condor /var/log/condor /var/run/condor /var/lib/condor/condor_config.local

	newconfd "${FILESDIR}"/condor.confd condor || die
	newinitd "${FILESDIR}"/condor.initd condor || die
}

pkg_postinst() {
	elog "Default configuration files have been installed"
	elog "You can customize it from there or provide your own"
	elog "in ${ROOT}etc/${PN}/condor_config*"

	elog "The condor ebuild is still under development."
	elog "Help us improve the ebuild in participating in:"
	elog "https://bugs.gentoo.org/show_bug.cgi?id=60281"
}
