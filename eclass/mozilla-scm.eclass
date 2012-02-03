# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# @ECLASS: mozilla-scm.eclass
# @MAINTAINER:
# Sardem FF7 <sardemff7.pub@gmail.com>
# @BLURB: This eclass provides Mozilla SCM building support


inherit mozilla-scm-fetch python

# @ECLASS-VARIABLE: EHG_REVISION
# @DESCRIPTION:
# Create working directory for specified revision, defaults to tip.
#
# EHG_REVISION is passed as a value for --rev parameter, so it can be more than
# just a revision, please consult `hg help revisions' for more details.
: ${EHG_REVISION:=tip}

[ "${PN}" != "nspr" ] && RDEPEND="~dev-libs/nspr-9999"
DEPEND="${RDEPEND}
	app-arch/zip
	dev-util/pkgconfig
	=dev-lang/python-2*[threads]

	meta-sync/mozilla-repositories
	"

EXPORT_FUNCTIONS pkg_setup

##
## eclass exported function
## pkg_setup
##
function mozilla-scm_pkg_setup {
	mozilla-scm-fetch_pkg_setup
	python_set_active_version 2
}
