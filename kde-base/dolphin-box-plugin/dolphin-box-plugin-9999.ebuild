# Distributed under the terms of the GNU General Public License v2
# $Header:

EAPI="5"

KDE_OVERRIDE_MINIMAL="4.7"
inherit kde4-base git-r3 cmake-utils

DESCRIPTION="Provides Dropbox integration in Dolphin."
EGIT_REPO_URI="git://anongit.kde.org/scratch/trichard/dolphin-box-plugin"
SRC_URI=""
HOMEPAGE="http://gitweb.kde.org/scratch/trichard/dolphin-box-plugin.git"

KEYWORDS="**"
IUSE=""
LICENSE="GPL-3"
DEPEND="
	$(add_kdebase_dep libkonq)
"

RDEPEND="${DEPEND}"
 
pkg_postinst() {
	elog ""
	elog "Quick start:"
	elog "  * Restart Dolphin"
	elog "  * Settings --> Configure Dolphin --> Services"
	elog "  * Check Dropbox"
	elog "  * Restart Dolphin"
}
