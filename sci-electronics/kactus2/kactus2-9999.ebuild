# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

PYTHON_COMPAT=( python3_{8..11} )
inherit python-r1 qmake-utils xdg

DESCRIPTION="A open source IP-XACT-based tool"
HOMEPAGE="
	https://research.tuni.fi/system-on-chip/tools/
	https://github.com/kactus2/kactus2dev
"

if [[ "${PV}" == "9999" ]] ; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/${PN}/${PN}dev.git"
else
	SRC_URI="https://github.com/${PN}/${PN}dev/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~arm ~arm64 ~hppa ~ppc ~ppc64 ~riscv ~x86"
	S="${WORKDIR}/${PN}dev-${PV}"
fi

LICENSE="GPL-2"
SLOT="0"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"
IUSE="+qt6 python"

RDEPEND="
	${PYTHON_DEPS}
	qt6? (
		dev-qt/qtbase:6[gui,xml,widgets]
		dev-qt/qttools:6[assistant]
		dev-qt/qtsvg:6
	)
	!qt6? (
		dev-qt/qtcore:5
		dev-qt/qtgui:5
		dev-qt/qthelp:5
		dev-qt/qtprintsupport:5
		dev-qt/qtsvg:5
		dev-qt/qtwidgets:5
		dev-qt/qtxml:5
	)
"

DEPEND="
	${RDEPEND}
"

BDEPEND="
	dev-lang/swig
"

src_prepare() {
	default
	# Fix QA pre-stripped warnings, bug 781674
	while IFS= read -r -d '' i; do
		echo "CONFIG+=nostrip" >> "${i}" || die
	done < <(find . -type f '(' -name "*.pro" ')' -print0)
	# Fix QTBIN_PATH
	if use qt6; then
		sed -i -e "s QTBIN_PATH=.* QTBIN_PATH=\"$(qt6_get_bindir)/\" " configure || die
	else
		sed -i -e "s QTBIN_PATH=.* QTBIN_PATH=\"$(qt5_get_bindir)/\" " configure || die
	fi
	sed -i -e "s ${QTBIN_PATH}qhelpgenerator ${QTBIN_PATH}../libexec/qhelpgenerator " configure || die
}

src_install() {
	# Can't use default, set INSTALL_ROOT and workaround parallel install bug
	emake -j1 INSTALL_ROOT="${D}" install
	python_install() {
		export PYTHON_C_FLAGS="$(python_get_CFLAGS)"
		export PYTHON_LIBS="$(python_get_LIBS)"
		pushd "PythonAPI" || die
		emake clean
		if use qt6; then
			eqmake6 PREFIX="$(python_get_library_path)"
		else
			eqmake5 PREFIX="$(python_get_library_path)"
		fi
		emake
		rm -rf _pythonAPI.so || die
		cp -rf libPythonAPI.so.1.0.0 _pythonAPI.so || die
		python_domodule _pythonAPI.so
		python_domodule pythonAPI.py
		popd
	}
	if use python; then
		python_foreach_impl python_install
	fi
}
