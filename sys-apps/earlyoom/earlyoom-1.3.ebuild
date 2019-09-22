# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Early OOM Daemon for Linux"
HOMEPAGE="https://github.com/rfjakob/earlyoom"

if [[ ${PV} = *9999* ]]; then
	EGIT_REPO_URI="https://github.com/rfjakob/${PN}"
        GIT_ECLASS="git-r3"
	SRC_URI=""
	KEYWORDS=""
else
	SRC_URI="https://github.com/rfjakob/earlyoom/archive/v$PV.tar.gz -> $P.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

inherit systemd ${GIT_ECLASS}

LICENSE="MIT-with-advertising"
SLOT="0"
IUSE="openrc systemd docs"

DEPEND="docs? ( app-text/pandoc )"
RDEPEND=""

src_compile() {
        emake earlyoom
        use docs && emake earlyoom.1
        use systemd && emake PREFIX=/usr earlyoom.service
}

src_install() {
        dobin earlyoom
        use docs && doman earlyoom.1

        insinto /etc/default
        newins earlyoom.default earlyoom

        use openrc && doinitd "$FILESDIR/$PN"
        use systemd && systemd_dounit earlyoom.service
}

