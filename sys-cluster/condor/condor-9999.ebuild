# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit eutils flag-o-matic cmake-utils git-2

DESCRIPTION="Workload management system for compute-intensive jobs"
HOMEPAGE="http://www.cs.wisc.edu/condor/"
#SRC_URI="ssh://chopin.cs.wisc.edu/p/condor/repository/CONDOR_SRC.git"
EGIT_REPO_URI=""

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS=""

IUSE="+cgroup classads drmaa examples gcb kbdd kerberos postgres soap ssl"

CDEPEND="sys-libs/zlib
	app-emulation/libvirt
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

DEPEND="${CDEPEND}
	dev-util/cmake"

S="${WORKDIR}/${P}"

pkg_setup() {
	enewgroup condor
	enewuser condor -1 "${ROOT}"bin/bash "${ROOT}var/lib/condor" condor
}

src_prepare() {
	# these two eauto* are to replicate the build_init script
	# not so sure they are really needed
	#eautoheader
	#eautoconf
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
	filter-flags "-O[s2-9]" "-O1"

	mycmakeargs=(
                -DPROPER=ON
		-DCLIPPED=ON
		-DWITH_LIBVIRT=ON
		-DWITH_GLOBUS=OFF
		-DWANT_MAN_PAGES=ON
                $(cmake-utils_use kerberos WITH_KRB5)
                $(cmake-utils_use soap WITH_GSOAP)
                $(cmake-utils_use ssl WITH_OPENSSL)
                $(cmake-utils_use gcb)
                $(cmake-utils_use drmaa)
                $(cmake-utils_use postgres WANT_CONTRIB)
                $(cmake-utils_use classads)
                $(cmake-utils_use kbdd HAVE_KBDD)
        )
		#-DUW_BUILD=OFF
		#-DBUILD_TESTS=OFF
		#-DENABLE_JAVA_TESTS=OFF
	#HAVE_BACKFILL:BOOL=ON
	#HAVE_BOINC:BOOL=ON


	cmake-utils_src_configure
}

src_compile() {
	# yet to find a way to parallelize compilation
	cmake-utils_src_make -j1 || die "emake failed"
	#MAKEOPTS="-j1"
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
