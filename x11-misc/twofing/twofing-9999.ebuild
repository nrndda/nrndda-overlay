EAPI=5

inherit git-r3

DESCRIPTION="Two-finger gestures recognition daemon."
HOMEPAGE="https://github.com/Plippo/twofing"
SRC_URI=""
EGIT_REPO_URI="https://github.com/Plippo/twofing.git"

LICENSE="MIT"
SLOT="0"
KEYWORDS=""
RDEPEND="
    x11-libs/libX11
    x11-libs/libXi
    x11-libs/libXrandr
    x11-libs/libXtst
"
DEPEND="${RDEPEND}"
