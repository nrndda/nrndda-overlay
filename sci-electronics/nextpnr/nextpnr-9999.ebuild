EAPI=8

PYTHON_COMPAT=( python3_{8..11} )
inherit git-r3 cmake

DESCRIPTION="portable FPGA place and route tool"
HOMEPAGE="https://github.com/YosysHQ/nextpnr"

# SRC_URI="https://github.com/YosysHQ/$PN/archive/$GIT_COMMIT.tar.gz -> $P.tar.gz"
EGIT_REPO_URI="https://github.com/YosysHQ/nextpnr.git"
LICENSE=ISC
SLOT=0

NEXTPNR_ARCHES="generic ice40 ecp5 nexus gowin fpga_interchange machxo2 mistral"
for use_arch in ${NEXTPNR_ARCHES}; do
	ALL_NEXTPNR_ARCHES+="nextpnr_arch_${use_arch} "
done
IUSE="python gui openmp +tbb +heap nextpnr_stable_arches nextpnr_experimental_arches ${ALL_NEXTPNR_ARCHES}"

REQUIRED_USE="
	|| ( nextpnr_stable_arches nextpnr_experimental_arches ${ALL_NEXTPNR_ARCHES[*]} )
	gui? ( python )
"
DEPEND="
	dev-libs/boost[python]
	tbb? ( dev-cpp/tbb )
	heap? ( dev-cpp/eigen:3 )
	gui? (
		dev-qt/qtcore:5
		dev-qt/qtgui:5
		dev-qt/qtopengl:5
		dev-qt/qtwidgets:5
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
BDEPEND="
	dev-python/pybind11
"

src_configure() {
	local enabled_arches
	for use_arch in ${NEXTPNR_ARCHES}; do
		if use nextpnr_experimental_arches; then
			enabled_arches+="all+alpha;"
		elif use nextpnr_stable_arches; then
			enabled_arches+="all;"
		elif use nextpnr_arch_${use_arch}; then
			enabled_arches+="${use_arch};"
		fi
	done
	local mycmakeargs=(
		-DARCH=$enabled_arches
		-DPYBIND11_INCLUDE_DIR=$(pybind11-config --cmakedir)
		-DBUILD_PYTHON=$(usex python)
		-DBUILD_GUI=$(usex gui)
		-DBUILD_HEAP=$(usex heap)
		-DUSE_OPENMP=$(usex openmp)
		-DUSE_IPO=YES
	)
	cmake_src_configure
}
