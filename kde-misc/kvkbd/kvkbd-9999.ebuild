# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/kde-misc/kvkbd/kvkbd-0.6-r1.ebuild,v 1.2 2014/04/24 15:05:37 johu Exp $

EAPI=6

inherit kde5 git-r3

KDEAPPS_ID="56019"

DESCRIPTION="A virtual keyboard for KDE"
HOMEPAGE="https://github.com/KDE/kvkbd"
SRC_URI=""
EGIT_REPO_URI="https://github.com/KDE/kvkbd.git"

LICENSE="GPL-3"
SLOT="5"
KEYWORDS="amd64 x86"
IUSE=""


DEPEND="$(add_frameworks_dep kdelibs4support)"
