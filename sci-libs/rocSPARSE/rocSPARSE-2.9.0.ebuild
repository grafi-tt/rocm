# Copyright
#

EAPI=7

inherit cmake-utils

DESCRIPTION="Common interface that provides Basic Linear Algebra Subroutines for sparse computation"
HOMEPAGE="https://github.com/ROCmSoftwarePlatform/rocSPARSE"
SRC_URI="https://github.com/ROCmSoftwarePlatform/rocSPARSE/archive/rocm-$(ver_cut 1-2).tar.gz -> rocSPARSE-${PV}.tar.gz"

LICENSE=""
SLOT="0"
KEYWORDS=""
IUSE="+gfx803 gfx900 gfx906 debug"
REQUIRED_USE="^^ ( gfx803 gfx900 gfx906 )"

#RDEPEND="=sys-devel/hip-$(ver_cut 1-2)*[hcc-backend]
#	 =sci-libs/rocPRIM-$(ver_cut 1-2)*"
RDEPEND="=sys-devel/hip-2.8*[hcc-backend]
	 =sci-libs/rocPRIM-$(ver_cut 1-2)*"
DEPEND="${RDEPEND}
	dev-util/cmake"

S="${WORKDIR}/rocSPARSE-rocm-$(ver_cut 1-2)"

rocSPARSE_V="0.1"

BUILD_DIR="${S}/build/release"

src_prepare() {
        cd ${S}

        sed -e "s: PREFIX rocsparse:# PREFIX rocsparse:" -i library/CMakeLists.txt
	sed -e "s:<INSTALL_INTERFACE\:include:<INSTALL_INTERFACE\:include/rocsparse/:" -i library/CMakeLists.txt
        sed -e "s:rocm_install_symlink_subdir(rocsparse):#rocm_install_symlink_subdir(rocsparse):" -i library/CMakeLists.txt

        eapply_user
	cmake-utils_src_prepare
}

src_configure() {
        # if the ISA is not set previous to the autodetection,
        # /opt/rocm/bin/rocm_agent_enumerator is executed,
        # this leads to a sandbox violation
        if use gfx803; then
                CurrentISA="gfx803"
        fi
        if use gfx900; then
                CurrentISA="gfx900"
        fi
        if use gfx906; then
                CurrentISA="gfx906"
        fi

#	export HCC_ROOT=/usr/lib/hcc/$(ver_cut 1-2)
	export HCC_ROOT=/usr/lib/hcc/2.8

	export hcc_DIR=${HCC_ROOT}/lib/cmake/hcc/
	export CXX=${HCC_ROOT}/bin/hcc

	local mycmakeargs=(
		-DBUILD_CLIENTS_SAMPLES=OFF
		-DAMDGPU_TARGETS="${CurrentISA}"
		-DCMAKE_INSTALL_PREFIX="/usr"
		-DCMAKE_INSTALL_INCLUDEDIR="include/rocsparse"
	)

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	chrpath --delete "${D}/usr/lib64/librocsparse.so.${rocSPARSE_V}"
}
