# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit kde5

DESCRIPTION="Integrate Chrome/Firefox better into Plasma through browser extensions"
HOMEPAGE="https://cgit.kde.org/plasma-browser-integration.git"

LICENSE="GPL-3+"
IUSE=""

DEPEND="
	$(add_qt_dep qtdbus)
	$(add_qt_dep qtgui)
	$(add_qt_dep qtwidgets)
	$(add_frameworks_dep kactivities)
	$(add_frameworks_dep kcoreaddons)
	$(add_frameworks_dep ki18n)
	$(add_frameworks_dep kio)
	$(add_frameworks_dep knotifications)
	$(add_frameworks_dep krunner)
	$(add_frameworks_dep kwindowsystem)
"
RDEPEND="${DEPEND}"
