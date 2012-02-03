# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# @ECLASS: mozilla-config.eclass
# @MAINTAINER:
# Sardem FF7 <sardemff7.pub@gmail.com>
# @BLURB: This eclass provides Mozilla app build support

WANT_AUTOCONF="2.1"

inherit base multilib toolchain-funcs autotools flag-o-matic pax-utils mozilla-scm

S="${WORKDIR}/${XULRUNNER_HG_MODULE}"

#
# Some per-application stuff
#
MOZILLA_FIVE_HOME="/usr/$(get_libdir)/${PN}"
case "${PN}" in
	firefox)
		MOZ_APPLICATION=browser
	;;
	thunderbird)
		MOZ_APPLICATION=mail
	;;
esac

RDEPEND="
	x11-libs/libXrender
	x11-libs/libXt
	x11-libs/libXmu
	>=sys-libs/zlib-1.1.4
	virtual/jpeg
	dev-libs/expat
	app-arch/unzip
	>=x11-libs/gtk+-2.14.0
	>=dev-libs/glib-2.26
	>=x11-libs/pango-1.10.1
	>=dev-libs/libIDL-0.8.0
	>=dev-libs/libevent-1.4.7
	!<x11-base/xorg-x11-6.7.0-r2

	>=sys-devel/binutils-2.16.1
	~dev-libs/nss-9999
	>=app-text/hunspell-1.2
	>=x11-libs/cairo-1.10.2[X]
	x11-libs/pixman
	dev-libs/libffi

	alsa? ( media-libs/alsa-lib )
	dbus? ( >=dev-libs/dbus-glib-0.72 )
	gconf? ( gnome-base/gconf:2 )
	libnotify? ( >=x11-libs/libnotify-0.4 )
	startup-notification? ( >=x11-libs/startup-notification-0.8 )
	system-sqlite? ( >=dev-db/sqlite-3.7.5[fts3,secure-delete,unlock-notify] )
	webm? ( >=media-libs/libvpx-0.9.7 )
	wifi? ( net-wireless/wireless-tools )
	"

DEPEND="${RDEPEND}
	meta-sync/mozilla-repositories[mozdom=]
	webm? ( dev-lang/yasm )
	>=sys-devel/gcc-4.1
	"

RDEPEND+="
	!net-libs/xulrunner
	!www-plugins/weave
	"

IUSE="+alsa bindist custom-optimization debug dbus gconf +ipc libnotify mozdom raw startup-notification +system-sqlite +webm wifi"


EXPORT_FUNCTIONS pkg_setup src_prepare src_configure src_install pkg_postinst

function mozilla-app_pkg_setup() {
	mozilla-scm_pkg_setup
	# Set by configure (plus USE_AUTOCONF=1), but useful for NSPR
	export MOZILLA_CLIENT=1
	export BUILD_OPT=1
	export NO_STATIC_LIB=1
	export USE_PTHREADS=1

	if [ "${XULRUNNER_HG_MODULE}" = "mozilla-aurora" ]; then
		MOZ_BRANDING=aurora
	elif use bindist; then
		MOZ_BRANDING=nightly
	else
		MOZ_BRANDING=official

		elog "You are enabling official branding. You may not redistribute this build"
		elog "to any users on your network or the internet. Doing so puts yourself into"
		elog "a legal problem with Mozilla Foundation"
	fi
}

function mozilla-app_src_prepare() {
	epatch "${FILESDIR}"/gcc46.patch

	# fix double symbols due to double -ljemalloc
	sed -i \
		-e '/^LIBS += $(JEMALLOC_LIBS)/s/^/#/' \
		xulrunner/stub/Makefile.in \
		|| die

	# Enable gnomebreakpad
	if use debug; then
		sed -i \
			-e "s:GNOME_DISABLE_CRASH_DIALOG=1:GNOME_DISABLE_CRASH_DIALOG=0:g" \
			build/unix/run-mozilla.sh \
			|| die "sed failed!"
	fi

	# tmp fix
	sed -i \
		-e '/XPIDL_LINK =/s|$(LIBXUL_DIST)/sdk/bin|$(DEPTH)/xpcom/typelib/xpt/tools|' \
		config/config.mk \
		js/src/config/config.mk \
		|| die "tmp fix failed (maybe the time to remove it)"

	# Gentoo install dirs
	sed -i \
		-e 's:$(datadir)/idl/$(MOZ_APP_NAME)-$(MOZ_APP_VERSION):$(includedir)/idl:' \
		-e 's:$(MOZ_APP_NAME)-$(MOZ_APP_VERSION):'${PN}':' \
		-e 's:$(MOZ_APP_NAME)-devel-$(MOZ_APP_VERSION):'${PN}':' \
		config/autoconf.mk.in \
		|| die "${MAJ_XUL_PV} sed failed!"

	eautoreconf

	cd js/src
	eautoreconf
}

mozconfig_annotate() {
	declare reason=$1 x ; shift
	[[ $# -gt 0 ]] || die "mozconfig_annotate missing flags for ${reason}\!"
	for x in ${*}; do
		echo "ac_add_options ${x} # ${reason}" >>.mozconfig
	done
}

mozconfig_flag() {
	mozconfig_annotate "USE-flag: $(useq $1 && echo +$1 || echo -$1)" "$2"
}

mozconfig_use_enable() {
	mozconfig_flag "$1" "$(use_enable "$@")"
}

mozconfig_use_with() {
	mozconfig_flag "$1" "$(use_with "$@")"
}

function mozilla-app_src_configure() {
	MAKEOPTS=${MAKEOPTS/--no-print-directory/}

	# Ensure that are plugins dir is enabled as default
	sed -i -e "s:/usr/lib/mozilla/plugins:/usr/$(get_libdir)/nsbrowser/plugins:" \
		"${S}"/xpcom/io/nsAppFileLocationProvider.cpp || die "sed failed to replace plugin path!"

	# hack added to workaround bug 299905 on hosts with libc that doesn't
	# support tls, (probably will only hit this condition with Gentoo Prefix)
	tc-has-tls -l || export ac_cv_thread_keyword=no


	####################################
	#
	# Setup the initial .mozconfig
	# See https://developer.mozilla.org/en/Configuring_Build_Options
	#
	####################################

	cp ${MOZ_APPLICATION}/config/mozconfig .mozconfig \
		|| die "cp mozconfig failed"

	####################################
	#
	# CFLAGS setup and ARCH support
	#
	####################################

	# Set optimization level
	if use custom-optimization; then
		local opt=-O2
		# Set optimization level based on CFLAGS
		if [[ ${ARCH} == x86 ]]; then
			if is-flag -O0; then
				opt=-O0
			elif is-flag -O1; then
				opt=-O1
			elif is-flag -Os; then
				opt=-Os
			fi
		elif is-flag -O3; then
			opt=-O3
		fi
		mozconfig_annotate 'USE-flag: +custom-optimization' --enable-optimize=$opt
	else
		# Enable Mozilla's default
		# It should be fine on all platform
		mozconfig_annotate 'Default optimization: Mozilla' --enable-optimize
	fi

	# Now strip optimization from CFLAGS so it doesn't end up in the
	# compile string
	filter-flags '-O*'

	# Strip over-aggressive CFLAGS - Mozilla supplies its own
	# fine-tuned CFLAGS and shouldn't be interfered with..  Do this
	# AFTER setting optimization above since strip-flags only allows
	# -O -O1 and -O2
	strip-flags

	if [[ $(gcc-major-version) -eq 3 ]]; then
		# Enable us to use flash, etc plugins compiled with gcc-2.95.3
		mozconfig_annotate "building with >=gcc-3" --enable-old-abi-compat-wrappers

		# Needed to build without warnings on gcc-3
		CXXFLAGS="${CXXFLAGS} -Wno-deprecated"

		if [[ "${ARCH}"  == x86 &&
			( $(gcc-minor-version) -lt 2 ||
				( $(gcc-minor-version) -eq 2 && $(gcc-micro-version) -lt 3 )
			) ]]
		then
			replace-flags -march=pentium4 -march=pentium3
			filter-flags -msse2
		fi
	elif [[ $(gcc-major-version) -lt 4 ]]; then
		append-flags -fno-stack-protector
	fi

	# Go a little faster; use less RAM
	append-flags "$MAKEEDIT_FLAGS"

	# Ensure we do not fail on i{3,5,7} processors that support	-mavx
	append-flags -mno-avx

	####################################
	#
	# mozconfig setup
	#
	####################################

	mozconfig_annotate 'Gentoo system' \
		--disable-installer \
		--disable-pedantic \
		--with-system-jpeg \
		--with-system-bz2 \
		--with-system-zlib \
		--disable-updater \
		--enable-system-cairo \
		--enable-system-hunspell \
		--enable-system-ffi \
		--disable-strip \
		--enable-default-toolkit=cairo-gtk2 \
		--disable-strip-libs \
		--disable-install-strip \
		--with-system-nspr \
		--with-nspr-prefix="${EPREFIX}"/usr \
		--with-system-nss \
		--with-nss-prefix="${EPREFIX}"/usr \
		--with-system-libevent="${EPREFIX}"/usr \
		--x-includes="${EPREFIX}"/usr/include \
		--x-libraries="${EPREFIX}"/usr/$(get_libdir) \
		--with-distribution-id=org.gentoo

	mozconfig_annotate 'Gentoo defaults' \
		--enable-gio \
		--enable-single-profile \
		--disable-profilesharing \
		--disable-profilelocking

	mozconfig_annotate 'Provide and use libmozjs' --enable-shared-js

	sed -i \
		-e '/--enable-application=/d' \
		-e '/--enable-extensions=/d'\
		.mozconfig
	local extensions="default"
	use mozdom && extensions+=",inspector"
	mozconfig_annotate 'Application defaults' \
		--enable-application=${MOZ_APPLICATION} \
		--with-default-mozilla-five-home="${MOZILLA_FIVE_HOME}" \
		--enable-extensions="${extensions}"

	mozconfig_annotate 'Basic features' \
		--enable-crypto \
		--enable-tracejit \
		--enable-pango \
		--enable-mathml \
		--enable-safe-browsing \
		--enable-storage \
		--enable-places \
		--enable-places_bookmarks

	# jemalloc won't build with older glibc
	! has_version ">=sys-libs/glibc-2.4" && mozconfig_annotate 'old glibc' --disable-jemalloc

	if [ "${MOZ_BRANDING}" = "official" ]; then
		mozconfig_annotate 'Official branding' \
			--enable-official-branding
	else
		mozconfig_annotate 'Unofficial branding' \
			--with-branding=${MOZ_APPLICATION}/branding/${MOZ_BRANDING}
	fi

	# Use system libraries
	mozconfig_use_enable alsa ogg
	mozconfig_use_enable alsa wave
	mozconfig_use_enable dbus
	mozconfig_use_enable gconf
	mozconfig_use_enable ipc # +ipc, upstream default
	mozconfig_use_enable libnotify
	mozconfig_use_enable raw
	mozconfig_use_enable startup-notification
	mozconfig_use_enable system-sqlite
	mozconfig_use_enable webm
	mozconfig_use_with   webm system-libvpx
	mozconfig_use_enable wifi necko-wifi


	# NOTE: Uses internal copy of libvpx
	if use webm && ! use alsa; then
		die "USE=webm needs USE=alsa"
	fi


	# Debug
	if use debug; then
		mozconfig_annotate 'Debug activated' \
			--disable-optimize \
			--enable-valgrind \
			--enable-debug=-ggdb \
			--enable-debug-modules=all \
			--enable-debugger-info-modules
	else
		mozconfig_annotate 'Debug deactivated' \
			--disable-debug \
			--disable-debug-symbols \
			--disable-tests
	fi

	# omni.jar breaks ff on xr
	# Bug 60668: Galeon doesn't build without oji enabled, so enable it
	# regardless of java setting.--enable-oji
	mozconfig_annotate 'Broken' \
		--disable-crashreporter \
		--enable-chrome-format=jar \
		--enable-oji

	mozconfig_annotate 'Deprecated' \
		--disable-gnomeui \
		--disable-gnomevfs


	# Currently --enable-elf-dynstr-gc only works for x86 and ppc,
	# thanks to Jason Wever <weeve@gentoo.org> for the fix.
	# -- This breaks now on ppc, no idea why
#	if use x86 || use ppc && [[ ${enable_optimize} != -O0 ]]; then
	if use x86 && [[ ${enable_optimize} != -O0 ]]; then
		mozconfig_annotate "${ARCH} optimized build" --enable-elf-dynstr-gc
	fi
#	fi

	echo
	echo '=========================================================='
	echo "Building ${PF} with the following configuration"
	grep '^ac_add_options' .mozconfig | while read ac opt hash reason; do
		[[ -z ${hash} || ${hash} == \# ]] \
			|| die "error reading mozconfig: ${ac} ${opt} ${hash} ${reason}"
		printf '    %-60s  %s\n' "${opt}" "${reason:-mozilla.org default}"
	done
	echo '=========================================================='
	echo

	CC="$(tc-getCC)" CXX="$(tc-getCXX)" LD="$(tc-getLD)" PYTHON="$(PYTHON)" econf "$@"
}

function mozilla-app_src_compile() {
	emake tier_app_dirs=xulrunner || die "emake failed"
}

function mozilla-app_src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	local prefdir="${ED}/${MOZILLA_FIVE_HOME}/defaults/pref"
	[[ -d "${prefdir}erences" ]] && prefdir+="erences"
	cp "${FILESDIR}"/default-prefs.js \
		"${prefdir}/all-gentoo.js" || \
		die "failed to cp default-prefs.js"

	local size branding_path icon
	branding_path="${S}"/${MOZ_APPLICATION}/branding/${MOZ_BRANDING}
	source "${branding_path}"/configure.sh
	iconsname=default
	case "${MOZ_APPLICATION}" in
		mail) iconsname=mailicon ;;
	esac
	targeticonname="${MOZ_APP_DISPLAYNAME,,}"

	# Install icons and .desktop for menu entry
	for size in 16 22 24 32 256; do
		insinto "/usr/share/icons/hicolor/${size}x${size}/apps"
		[ -f "${branding_path}/${iconsname}${size}.png" ] && {
			newins "${branding_path}/${iconsname}${size}.png" "${targeticonname}.png" || die
		}
	done

	# The 128x128 icon has a different name
	insinto "/usr/share/icons/hicolor/128x128/apps"
		[ -f "${branding_path}/mozicon128.png" ] && {
			newins "${branding_path}/mozicon128.png" "${targeticonname}.png" || die
		}

	# Install a 48x48 icon into /usr/share/pixmaps for legacy DEs
	newicon "${branding_path}/content/icon48.png" "${targeticonname}.png" || die
	newmenu "${FILESDIR}/${PN}.desktop" "${PN}.desktop" || die

	sed -i -e "s:@NAME@:${MOZ_APP_DISPLAYNAME}:" -e "s:@ICON@:${targeticonname}:" \
		"${ED}/usr/share/applications/${PN}.desktop" || die

	# Add StartupNotify=true bug 237317
	if use startup-notification ; then
		echo "StartupNotify=true" >> "${ED}"/usr/share/applications/${PN}.desktop
	fi

	pax-mark m "${ED}"/${MOZILLA_FIVE_HOME}/plugin-container
	pax-mark m "${ED}"/${MOZILLA_FIVE_HOME}/${PN}

	# Plugins dir
	dosym ../nsbrowser/plugins "${MOZILLA_FIVE_HOME}"/plugins \
		|| die "failed to symlink"
}

##
## eclass exported function
## pkg_postinst
##
function mozilla-app_pkg_postinst {
	ewarn "All the packages built against ${PN} won't compile,"
	ewarn "any package that fails to build warrants a bug report."

	inherit fdo-mime
	# Update mimedb for the new .desktop file
	fdo-mime_desktop_database_update

	ewarn "This is highly experimental DO NOT file a bug report"
	ewarn "on Gentoo's bugzilla, please visit the Mozilla one instead"

	einfo "Don't forget to sync with meta-sync/mozilla-repositories"
}
