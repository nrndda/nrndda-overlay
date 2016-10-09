# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit eutils systemd

DESCRIPTION="Userspace OOM killer daemon"
HOMEPAGE="https://github.com/rfjakob/earlyoom"

SRC_URI="https://github.com/rfjakob/${PN}/archive/v${PV}.tar.gz"
KEYWORDS="~x86 ~amd64"

LICENSE="MIT"
SLOT="0"
IUSE="systemd sysv"

src_install() {
	dosbin "${S}"/earlyoom

        if use systemd; then
		sed -i -e 's/\/usr\/local\/sbin/\/usr\/sbin/g' "${S}"/earlyoom.service
                systemd_dounit "${S}"/earlyoom.service
        fi

        if use sysv; then
                newinitd "${S}"/earlyoom.initscript earlyoom
        fi
}
