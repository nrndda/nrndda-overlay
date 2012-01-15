# Distributed under the terms of the GNU General Public License v2
# $Header:

EAPI="4"

KDE_OVERRIDE_MINIMAL="4.7"
inherit kde4-base git-2 cmake-utils

DESCRIPTION="Provides Dropbox integration in Dolphin."
EGIT_REPO_URI="git://anongit.kde.org/scratch/trichard/dolphin-box-plugin"
SRC_URI=""
HOMEPAGE="http://gitweb.kde.org/scratch/trichard/dolphin-box-plugin.git"

KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
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
