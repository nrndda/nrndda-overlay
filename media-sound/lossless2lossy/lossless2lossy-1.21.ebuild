# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=7

DESCRIPTION="A conversion script for mass converting your music collection from one format to another"
HOMEPAGE="http://lossless2lossy.sourceforge.net/"
SRC_URI="http://downloads.sourceforge.net/${PN}/${PN}-v${PV}.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="ape flac mp3 vorbis wavpack"

RDEPEND="ape? ( media-sound/mac )
	flac? ( media-libs/flac )
	mp3? ( media-sound/lame )
	vorbis?  ( media-libs/libvorbis )
	wavpack? ( media-sound/wavpack )
	media-sound/id3v2"

S="${WORKDIR}"

src_install() {
	newbin lossless2lossy-v${PV} lossless2lossy || die
}
