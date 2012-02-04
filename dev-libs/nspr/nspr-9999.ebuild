# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

inherit mozilla-scm

DESCRIPTION="Netscape Portable Runtime"
HOMEPAGE="http://www.mozilla.org/projects/nspr/"

KEYWORDS="**"
IUSE="debug static-libs"

src_prepare() {
	mkdir inst
	#epatch "${FILESDIR}"/${PN}-4.7.0-prtime.patch
	epatch "${FILESDIR}"/libs.patch
	epatch "${FILESDIR}"/pkgconfig.patch
	sed -i -e 's/perl5//g' nsprpub/configure || die

	# Respect LDFLAGS
	sed -i -e 's/\$(MKSHLIB) \$(OBJS)/\$(MKSHLIB) \$(LDFLAGS) \$(OBJS)/g' \
		nsprpub/config/rules.mk
}

src_configure() {
	cd "${S}"/build

	ECONF_SOURCE="../nsprpub" econf \
		$(use_enable amd64 64bit) \
		$(use_enable debug) \
		$(use_enable !debug optimize) \
		--libdir="${EPREFIX}/usr/$(get_libdir)" \
		|| die "econf failed"
}

src_compile() {
	cd "${S}"/build
	emake CC="$(tc-getCC)" CXX="$(tc-getCXX)" || die "failed to build"
}

src_install () {
	# Their build system is royally confusing, as usual
	cd "${S}"/build
	emake DESTDIR="${D}" install || die "emake install failed"

	cd "${ED}"/usr/$(get_libdir)
	if ! use static-libs; then
		for file in *.a; do
			rm -f ${file} || die "failed to remove static libraries."
		done
	fi

	local n=
	MINOR_VERSION=$(sed -n -r -e 's|.*NSPR_[0-9]+_([0-9]+)(_[0-9]+)?.*|\1|p' "${S}"/nsprpub/TAG-INFO)
	for file in *$(get_libname); do
		n=${file%$(get_libname)}$(get_libname ${MINOR_VERSION})
		mv ${file} ${n} || die "failed to mv files around"
		ln -s ${n} ${file} || die "failed to symlink files."
	done

	# Remove stupid files in /usr/bin
	rm -f "${ED}"/usr/bin/prerr.properties || die "failed to cleanup unneeded files"
}

pkg_postinst() {
	ewarn
	ewarn "Please make sure you run revdep-rebuild after upgrade."
	ewarn "This is *extremely* important to ensure your system nspr works properly."
	ewarn
}
