# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

KEYWORDS=""
EGO_PN="github.com/odeke-em/drive/..."
EGIT_COMMIT="master"
SRC_URI="https://${EGO_PN%/*}/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz
https://github.com/GoogleCloudPlatform/gcloud-golang/archive/master.tar.gz -> gcloud-golang-master.tar.gz
https://github.com/boltdb/bolt/archive/master.tar.gz -> bolt-master.tar.gz
https://github.com/cheggaaa/pb/archive/master.tar.gz -> pb-master.tar.gz
https://github.com/codegangsta/inject/archive/master.tar.gz -> inject-master.tar.gz
https://github.com/go-martini/martini/archive/master.tar.gz -> martini-master.tar.gz
https://github.com/golang/crypto/archive/master.tar.gz -> crypto-master.tar.gz
https://github.com/golang/net/archive/master.tar.gz -> net-master.tar.gz
https://github.com/golang/oauth2/archive/master.tar.gz -> oauth2-master.tar.gz
https://github.com/golang/protobuf/archive/master.tar.gz -> golang-master.tar.gz
https://github.com/google/google-api-go-client/archive/master.tar.gz -> google-api-go-client-master.tar.gz
https://github.com/googleapis/gax-go/archive/master.tar.gz -> gax-go-master.tar.gz
https://github.com/grpc/grpc-go/archive/master.tar.gz -> grpc-go-master.tar.gz
https://github.com/martini-contrib/binding/archive/master.tar.gz -> binding-master.tar.gz
https://github.com/mattn/go-isatty/archive/master.tar.gz -> go-isatty-master.tar.gz
https://github.com/mattn/go-runewidth/archive/master.tar.gz -> go-runewidth-master.tar.gz
https://github.com/odeke-em/cache/archive/master.tar.gz -> cache-master.tar.gz
https://github.com/odeke-em/cli-spinner/archive/master.tar.gz -> cli-spinner-master.tar.gz
https://github.com/odeke-em/command/archive/master.tar.gz -> command-master.tar.gz
https://github.com/odeke-em/exponential-backoff/archive/master.tar.gz -> exponential-backoff-master.tar.gz
https://github.com/odeke-em/extractor/archive/master.tar.gz -> extractor-master.tar.gz
https://github.com/odeke-em/go-utils/archive/master.tar.gz -> go-utils-master.tar.gz
https://github.com/odeke-em/go-uuid/archive/master.tar.gz -> go-uuid-master.tar.gz
https://github.com/odeke-em/log/archive/master.tar.gz -> log-master.tar.gz
https://github.com/odeke-em/meddler/archive/master.tar.gz -> meddler-master.tar.gz
https://github.com/odeke-em/namespace/archive/master.tar.gz -> namespace-master.tar.gz
https://github.com/odeke-em/pretty-words/archive/master.tar.gz -> pretty-words-master.tar.gz
https://github.com/odeke-em/ripper/archive/master.tar.gz -> ripper-master.tar.gz
https://github.com/odeke-em/rsc/archive/master.tar.gz -> rsc-master.tar.gz
https://github.com/odeke-em/semalim/archive/master.tar.gz -> semalim-master.tar.gz
https://github.com/odeke-em/statos/archive/master.tar.gz -> statos-master.tar.gz
https://github.com/skratchdot/open-golang/archive/master.tar.gz -> open-golang-master.tar.gz"
DESCRIPTION="Google Drive client for the commandline"
HOMEPAGE="https://${EGO_PN%/*}"
LICENSE="Apache-2.0"
SLOT="0"
IUSE=""
DEPEND="dev-lang/go:="

get_archive_go_package() {
	local archive=${1} uri x
	case ${archive} in
		oauth2-*) echo "oauth2-* golang.org/x/oauth2"; return;;
		google-api-go-client-*) echo "google-api-go-client-* google.golang.org/api"; return;;
		gcloud-golang-*) echo "google-cloud-go-* cloud.google.com/go"; return;;
		grpc-go-*) echo "grpc-go-* google.golang.org/grpc"; return;;
		net-*) echo "net-* golang.org/x/net"; return;;
		crypto-*) echo "crypto-* golang.org/x/crypto"; return;;
	esac
	for x in ${SRC_URI}; do
		if [[ ${x} == http* ]]; then
			uri=${x}
		elif [[ ${x} == ${archive} ]]; then
			break
		fi
	done
	uri=${uri#https://}
	uri=${uri%/archive/*}
	echo "${uri##*/}-* ${uri}"
}

unpack_go_packages() {
	local go_package pattern x
	# Unpack packages to appropriate locations for GOPATH
	for x in ${A}; do
		unpack ${x}
		if [[ ${x} == *.tar.gz ]]; then
			go_package=$(get_archive_go_package ${x})
			pattern=${go_package%% *}
			go_package=${go_package##* }
			if [[ ${x%.tar.gz} -ef ${S} ]]; then
				mv "${S}"{,_} || die
				mkdir -p "${S}/src/${go_package%/*}" || die
				mv "${S}"_ "${S}/src/${go_package}" || die || die
			else
				mkdir -p "${S}/src/${go_package%/*}" || die
				for x in ${pattern}; do
					if [[ ! ${x} -ef ${S} ]]; then
						mv "${x}" "${S}/src/${go_package}" || die
					fi
				done
			fi
		fi
	done
}

src_unpack() {
	unpack_go_packages
}

src_prepare() {
	default
	rm -rf "${S}/src/${EGO_PN%/*}/drive-gen/Godeps/_workspace" || die
}

src_compile() {
	GOPATH="${WORKDIR}/${P}" \
		go install -v -work -x ${EGO_BUILD_FLAGS} "${EGO_PN}" || die
}

src_install() {
	dodoc "${S}/src/${EGO_PN%/*}/README.md"
	dobin "${S}/bin/drive"{,-server}
}
