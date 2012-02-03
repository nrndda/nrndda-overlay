# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# @ECLASS: mozilla-scm-fetch.eclass
# @MAINTAINER:
# Sardem FF7 <sardemff7.pub@gmail.com>
# @BLURB: This eclass provides Mozilla SCM fetching support

MOZ_HG_BASE_URI="http://hg.mozilla.org"

XULRUNNER_HG_MODULE="mozilla-central"
MOZDOM_HG_MODULE="dom-inspector"
THUNDERBIRD_HG_MODULE="comm-central"
LDAP_SDKS_HG_MODULE="projects/ldap-sdks"

# Enigmail CVS stuff
ECVS_USER="guest"
ECVS_PASS="guest"
ECVS_SERVER="mozdev.org:/cvs"
ECVS_MODULE="enigmail/src"

inherit eutils

MOZ_HG_BASE_URI="http://hg.mozilla.org"


# @ECLASS-VARIABLE: XULRUNNER_HG_MODULE
# @DESCRIPTION:
# The xulrunner module to use
#
# Default to mozilla-central, you may want
# to use mozilla-aurora
: ${XULRUNNER_HG_MODULE:=mozilla-central}
MOZDOM_HG_MODULE="dom-inspector"

LICENSE="|| ( MPL-1.1 GPL-2 LGPL-2.1 )"
SLOT="0"
SRC_URI=""
S="${WORKDIR}/${XULRUNNER_HG_MODULE}"

# @ECLASS-VARIABLE: EHG_STORE_DIR
# @DESCRIPTION:
# Mercurial sources store directory. Users may override this in /etc/make.conf
: ${EHG_STORE_DIR:=${PORTAGE_ACTUAL_DISTDIR:-${DISTDIR}}/hg-src}


# @ECLASS-VARIABLE: EHG_QUIET
# @DESCRIPTION:
# Force the Mercurial commands to be quiet

# @ECLASS-VARIABLE: EHG_CLONE_CMD
: ${EHG_CLONE_CMD:=hg clone ${EHG_QUIET:+--quiet} --pull --noupdate}

# @ECLASS-VARIABLE: EHG_PULL_CMD
: ${EHG_PULL_CMD:=hg pull ${EHG_QUIET:+--quiet}}

# @ECLASS-VARIABLE: EHG_OFFLINE
# @DESCRIPTION:
# Should be non-empty if offline to avoid cloning/updating
: ${EHG_OFFLINE:=${ESCM_OFFLINE}}

function moz_hg_fetch {
	[[ -n "${EHG_OFFLINE}" ]] && return
	debug-print-function ${FUNCNAME} ${*}

	local repo=${1}
	local module="$(basename "${repo}")"


	# Should be set but blank to prevent using $HOME/.hgrc
	export HGRCPATH=

	# Check ${EHG_STORE_DIR} directory:
	addwrite "$(dirname "${EHG_STORE_DIR}")" || die "addwrite failed"
	if [[ ! -d "${EHG_STORE_DIR}" ]]; then
		mkdir -p "${EHG_STORE_DIR}" || die "failed to create ${EHG_STORE_DIR}"
		chmod -f g+rw "${EHG_STORE_DIR}" || \
			die "failed to chown ${EHG_STORE_DIR}"
	fi

	# Create project directory:
	mkdir -p "${EHG_STORE_DIR}/mozilla" || \
		die "failed to create ${EHG_STORE_DIR}/mozilla"
	chmod -f g+rw "${EHG_STORE_DIR}/mozilla" || \
		echo "Warning: failed to chmod g+rw mozilla"
	cd "${EHG_STORE_DIR}/mozilla" || \
		die "failed to cd to ${EHG_STORE_DIR}/mozilla"

	# Clone/update repository:
	if [[ ! -d "${module}" ]]; then
		einfo "Cloning ${repo} to ${EHG_STORE_DIR}/mozilla/${module}"
		${EHG_CLONE_CMD} "${repo}" "${module}" || {
			rm -rf "${module}"
			die "failed to clone ${repo}"
		}
		cd "${module}"
	else
		einfo "Updating ${EHG_STORE_DIR}/mozilla/${module} from ${repo}"
		cd "${module}" || die "failed to cd to ${module}"
		${EHG_PULL_CMD} || die "update failed"
	fi
}

function moz_hg_unpack {
	debug-print-function ${FUNCNAME} ${*}

	local module="$(basename "${1}")"
	local dest="${WORKDIR}/${2:-${module}}"


	# Should be set but blank to prevent using $HOME/.hgrc
	export HGRCPATH=

	# Checkout working copy:
	einfo "Creating working directory for ${module} (target revision: ${EHG_REVISION})"
	hg archive \
		${EHG_QUIET_CMD_OPT} \
		--rev="${EHG_REVISION}" \
		-R "${EHG_STORE_DIR}/mozilla/${module}" \
		"${dest}" || die "hg clone failed"
	einfo "Work directory: ${dest}"
}

EXPORT_FUNCTIONS pkg_setup src_unpack

##
## eclass exported function
## pkg_setup
##
function mozilla-scm-fetch_pkg_setup {
	# Ensure we always build with C locale.
	export LANG="C"
	export LC_ALL="C"
	export LC_MESSAGES="C"
	export LC_CTYPE="C"
}

##
## eclass exported function
## src_unpack
##
function mozilla-scm-fetch_src_unpack {
	local base_dest=${1:-${XULRUNNER_HG_MODULE}}
	addwrite "$(dirname "${EHG_STORE_DIR}")" || die "addwrite failed"
	moz_hg_unpack "${XULRUNNER_HG_MODULE}" "${base_dest}"
	use mozdom && moz_hg_unpack "${MOZDOM_HG_MODULE}" "${base_dest}/extensions/inspector"
}
