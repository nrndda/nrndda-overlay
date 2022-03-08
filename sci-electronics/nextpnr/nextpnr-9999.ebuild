EAPI=7
DESCRIPTION="portable FPGA place and route tool"
HOMEPAGE="https://github.com/YosysHQ/nextpnr"

inherit git-r3 cmake-utils

# SRC_URI="https://github.com/YosysHQ/$PN/archive/$GIT_COMMIT.tar.gz -> $P.tar.gz"
EGIT_REPO_URI="https://github.com/YosysHQ/nextpnr.git"
LICENSE=ISC
SLOT=0

NEXTPNR_ARCHES="ice40 ecp5 nexus gowin generic"
for use_arch in ${NEXTPNR_ARCHES}; do
	ALL_NEXTPNR_ARCHES+="nextpnr_arch_${use_arch} "
done
IUSE="gui openmp +heap ${ALL_NEXTPNR_ARCHES}"

REQUIRED_USE="|| ( ${ALL_NEXTPNR_ARCHES[*]} )"
DEPEND="
	dev-libs/boost[python]
	heap? (
		dev-cpp/eigen
	)
	gui? (
		dev-qt/qtcore:5
		virtual/opengl
	)
	nextpnr_arch_ice40? (
			  sci-electronics/icestorm
			>=sci-electronics/yosys-0.8
	)
	nextpnr_arch_ecp5? (
			  sci-electronics/prjtrellis
			 >sci-electronics/yosys-0.8
	)
"

src_configure() {
	local enabled_arches
	for use_arch in ${NEXTPNR_ARCHES}; do
		if use nextpnr_arch_${use_arch}; then
			enabled_arches+="${use_arch};"
		fi
	done
	local mycmakeargs=(
		-DARCH=$enabled_arches
		$(usex nextpnr_arch_ice40 -DICEBOX_ROOT=/usr/share/icebox "")
		$(usex nextpnr_arch_ecp5 -DTRELLIS_ROOT=/usr/share/trellis "")
		-DBUILD_GUI=$(usex gui)
		-DBUILD_HEAP=$(usex heap)
	)
	cmake-utils_src_configure
}
