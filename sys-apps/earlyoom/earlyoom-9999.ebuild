# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit eutils systemd git-r3

DESCRIPTION="Userspace OOM killer daemon"
HOMEPAGE="https://github.com/rfjakob/earlyoom"

EGIT_REPO_URI="https://github.com/rfjakob/${PN}"
SRC_URI=""
KEYWORDS=""

LICENSE="MIT"
SLOT="0"
IUSE="systemd sysv"

src_install() {
	dosbin "${S}"/earlyoom

        if use systemd; then
                systemd_dounit "${S}"/earlyoom.service
		sed -i -e 's/\/usr\/local\/bin/\/usr\/sbin/g' "${S}"/earlyoom.service
        fi

        if use sysv; then
                newinitd "${S}"/earlyoom.initscript earlyoom
        fi
}
