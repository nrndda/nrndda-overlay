# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit fdo-mime udev unpacker

MY_PN="draftsight"
MY_P="${MY_PN}-${PV}"
DESCRIPTION="Professional 2D CAD application, supporting DWT, DXF and DWG."
HOMEPAGE="http://www.3ds.com/products/draftsight/free-cad-software/"
# The libaudio requirement is due to ABI_X86 not being stable enough yet.
# See bug #463942 for the initial reason this was inserted.
SRC_URI="${MY_P}.deb
amd64? ( http://dev.gentoo.org/~moult/draftsight/libaudio.tar.gz )"

LICENSE="${MY_PN}"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
S="${WORKDIR}"

QA_PRESTRIPPED="opt/dassault-systemes/${MY_PN}/bin/DWGConverter
	amd64? ( opt/dassault-systemes/${MY_PN}/lib/libaudio.so.2 )"
QA_TEXTRELS="opt/dassault-systemes/${MY_PN}/lib/libDDKERNEL.so.1"
QA_EXECSTACK="opt/dassault-systemes/${MY_PN}/bin/FxCrashRptApp
opt/dassault-systemes/${MY_PN}/lib/libDDKERNEL.so.1"

RESTRICT="fetch"
DEPEND=""
RDEPEND="amd64? (
		app-emulation/emul-linux-x86-baselibs
		app-emulation/emul-linux-x86-opengl
		app-emulation/emul-linux-x86-qtlibs
		app-emulation/emul-linux-x86-soundlibs
		app-emulation/emul-linux-x86-xlibs
		)
	!amd64? (
		sys-libs/zlib
		net-print/cups
		dev-libs/expat
		dev-libs/glib:2
		media-libs/glu
		media-libs/phonon
		dev-qt/qtcore:4
		dev-qt/qtdbus:4
		dev-qt/qtgui:4
		dev-qt/qtopengl:4
		dev-qt/qtsql:4
		dev-qt/qtwebkit:4
		dev-qt/qtsvg:4
		media-libs/alsa-lib
		media-libs/fontconfig
		media-libs/freetype
		x11-libs/libICE
		x11-libs/libSM
		x11-libs/libX11
		x11-libs/libXext
		x11-libs/libXrender
		x11-libs/libXt
		media-libs/nas
		)"

pkg_nofetch() {
	einfo "Upstream has a mandatory EULA agreement to download this file."
	einfo "Please navigate your browser to:"
	einfo "http://www.3ds.com/products/draftsight/download-draftsight/"
	einfo "Click \"Download DraftSight for Ubuntu (Beta V1R5.1)\""
	einfo "Download the deb file and move it to ${DISTDIR}/${MY_P}.deb"
	if use amd64 ; then
		einfo "Then download http://dev.gentoo.org/~moult/draftsight/libaudio.tar.gz"
		einfo "And move the file to ${DISTDIR}/"
	fi
}

src_install() {
	cp -R "${WORKDIR}/opt" "${D}"
	exeinto /usr/bin
	doexe "${FILESDIR}/${MY_PN}"

	if use amd64 ; then
		insinto /opt/dassault-systemes/DraftSight/Libraries/
		doins libaudio.so.2
	fi
}

pkg_postinst() {
	elog "To use DraftSight as your default viewer for DWG, DXF, and DWT"
	elog "Please run the following commands respectively as your normal user:"
	elog "xdg-mime default \"dassault-systemes\"_\"draftsight.desktop\" \"application/vnd.dassault-systemes.draftsight-dwg\""
	elog "xdg-mime default \"dassault-systemes\"_\"draftsight.desktop\" \"application/vnd.dassault-systemes.draftsight-dxf\""
	elog "xdg-mime default \"dassault-systemes\"_\"draftsight.desktop\" \"application/vnd.dassault-systemes.draftsight-dwt\""

	local ICON_SIZES="16 32 48 64 128"

	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
	for size in ${ICON_SIZES} ; do
		xdg-icon-resource install --noupdate --novendor --context mimetypes \
			--mode system --size ${size} \
			"${ROOT}/opt/dassault-systemes/DraftSight/Resources/pixmaps/${size}x${size}/program.png" \
			"application-vnd.dassault-systemes.draftsight-dwg" \
			|| die "icon resource installation failed"
		xdg-icon-resource install --noupdate --novendor --theme gnome --context \
			mimetypes --mode system --size ${size} \
			"${ROOT}/opt/dassault-systemes/DraftSight/Resources/pixmaps/${size}x${size}/program.png" \
			"application-vnd.dassault-systemes.draftsight-dwg" \
			|| die "icon resource installation failed"
		xdg-icon-resource install --noupdate --novendor --context mimetypes \
			--mode system --size ${size} \
			"${ROOT}/opt/dassault-systemes/DraftSight/Resources/pixmaps/${size}x${size}/file-dwg.png" \
			"application-vnd.dassault-systemes.draftsight-dwg" \
			|| die "icon resource installation failed"
		xdg-icon-resource install --noupdate --novendor --theme gnome --context \
			mimetypes --mode system --size ${size} \
			"${ROOT}/opt/dassault-systemes/DraftSight/Resources/pixmaps/${size}x${size}/file-dwg.png" \
			"application-vnd.dassault-systemes.draftsight-dwg" \
			|| die "icon resource installation failed"
		xdg-icon-resource install --noupdate --novendor --context mimetypes \
			--mode system --size ${size} \
			"${ROOT}/opt/dassault-systemes/DraftSight/Resources/pixmaps/${size}x${size}/file-dxf.png" \
			"application-vnd.dassault-systemes.draftsight-dxf" \
			|| die "icon resource installation failed"
		xdg-icon-resource install --noupdate --novendor --theme gnome --context \
			mimetypes --mode system --size ${size} \
			"${ROOT}/opt/dassault-systemes/DraftSight/Resources/pixmaps/${size}x${size}/file-dxf.png" \
			"application-vnd.dassault-systemes.draftsight-dxf" \
			|| die "icon resource installation failed"
		xdg-icon-resource install --noupdate --novendor --context mimetypes \
			--mode system --size ${size} \
			"${ROOT}/opt/dassault-systemes/DraftSight/Resources/pixmaps/${size}x${size}/file-dwt.png" \
			"application-vnd.dassault-systemes.draftsight-dwt" \
			|| die "icon resource installation failed"
		xdg-icon-resource install --noupdate --novendor --theme gnome --context \
			mimetypes --mode system --size ${size} \
			"${ROOT}/opt/dassault-systemes/DraftSight/Resources/pixmaps/${size}x${size}/file-dwt.png" \
			"application-vnd.dassault-systemes.draftsight-dwt" \
			|| die "icon resource installation failed"
	done
	xdg-icon-resource forceupdate

	# prepare for dongle
	udev_dorules "${FILESDIR}"/10-ft-rockey.rules
}

pkg_prerm() {
	local ICON_SIZES="16 32 48 64 128"

	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
	for size in ${ICON_SIZES} ; do
		xdg-icon-resource uninstall --noupdate --context apps --mode system \
			--size ${size} "dassault-systemes.draftsight" \
			|| ewarn "icon uninstall failed"
		xdg-icon-resource uninstall --noupdate --context apps --theme gnome \
			--mode system --size ${size} "dassault-systemes.draftsight" \
			|| ewarn "icon uninstall failed"
		xdg-icon-resource uninstall --noupdate --context mimetypes --mode system \
			--size ${size} "application-vnd.dassault-systemes.draftsight-dwg" \
			|| ewarn "icon uninstall failed"
		xdg-icon-resource uninstall --noupdate --context mimetypes --theme gnome \
			--mode system --size ${size} \
			"application-vnd.dassault-systemes.draftsight-dwg" \
			|| ewarn "icon uninstall failed"
		xdg-icon-resource uninstall --noupdate --context mimetypes --mode system \
			--size ${size} "application-vnd.dassault-systemes.draftsight-dxf" \
			|| ewarn "icon uninstall failed"
		xdg-icon-resource uninstall --noupdate --context mimetypes --theme gnome \
			--mode system --size ${size} \
			"application-vnd.dassault-systemes.draftsight-dxf" \
			|| ewarn "icon uninstall failed"
		xdg-icon-resource uninstall --noupdate --context mimetypes --mode system \
			--size ${size} "application-vnd.dassault-systemes.draftsight-dwt" \
			|| ewarn "icon uninstall failed"
		xdg-icon-resource uninstall --noupdate --context mimetypes --theme gnome \
			--mode system --size ${size} \
			"application-vnd.dassault-systemes.draftsight-dwt" \
			|| ewarn "icon uninstall failed"
	done
	xdg-icon-resource forceupdate

	# remove dongle preparing
	if [ "${ROOT}/etc/udev/rules.d/" ]; then
	  rm -f "${ROOT}/etc/udev/rules.d/10-ft-rockey.rules"
	fi
}
