# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit mozilla-scm-fetch
use enigmail && inherit cvs


DESCRIPTION="Mozilla Mercurial repositories"
HOMEPAGE="${MOZ_HG_BASE_URI}"

KEYWORDS="~amd64 ~x86"
IUSE="enigmail mozdom thunderbird"

REQUIRE_USE="
	enigmail? ( thunderbird )
	"

DEPEND="
	dev-vcs/mercurial
	"
RDEPEND=""

S="${WORKDIR}"

function src_unpack {
	moz_hg_fetch "${MOZ_HG_BASE_URI}/${XULRUNNER_HG_MODULE}/"
	use mozdom && moz_hg_fetch "${MOZ_HG_BASE_URI}/${MOZDOM_HG_MODULE}/"
	if use thunderbird; then
		moz_hg_fetch "${MOZ_HG_BASE_URI}/${THUNDERBIRD_HG_MODULE}"
		moz_hg_fetch "${MOZ_HG_BASE_URI}/${LDAP_SDKS_HG_MODULE}"
		use enigmail && cvs_src_unpack
	fi
}
