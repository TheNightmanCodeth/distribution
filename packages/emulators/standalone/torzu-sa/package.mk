# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="torzu-sa"
PKG_VERSION="02cfee3f184e6fdcc3b483ef399fb5d2bb1e8ec7"
PKG_SITE="https://notabug.org/litucks/torzu"
PKG_URL="${PKG_SITE}.git"
PKG_LICENSE="GPLv3"
PKG_TOOLCHAIN="cmake"
PKG_DEPENDS_TARGET="toolchain linux libzip glibc systemd pulseaudio boost mesa xwayland glew-cmake libevdev curl ffmpeg libpng zlib SDL2 qt6 llvm"
PKG_DEPENDS_UNPACK="spirv-headers spirv-tools"
PKG_LONGDESC="Switch Emulator"

if [ "${OPENGL_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
fi

if [ "${VULKAN_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" vulkan-loader vulkan-headers"
  PKG_CMAKE_OPTS_TARGET+=" -DUSE_VULKAN=ON"
else
  PKG_CMAKE_OPTS_TARGET+=" -DUSE_VULKAN=OFF"
fi

post_unpack() {
  cd ${PKG_BUILD} && git submodule update --init --recursive
  rm -rf ${PKG_BUILD}/externals/SPIRV-Headers/*
  mkdir -p ${PKG_BUILD}/externals/SPIRV-Headers
    tar --strip-components=1 \
      -xf "${SOURCES}/spirv-headers/spirv-headers-$(get_pkg_version spirv-headers).tar.gz" \
      -C "${PKG_BUILD}/externals/SPIRV-Headers"

  rm -rf ${PKG_BUILD}/externals/SPIRV-Tools/*
  mkdir -p ${PKG_BUILD}/externals/SPIRV-Tools
    tar --strip-components=1 \
      -xf "${SOURCES}/spirv-tools/spirv-tools-$(get_pkg_version spirv-tools).tar.gz" \
      -C "${PKG_BUILD}/externals/SPIRV-Tools"
}

pre_build_target() {
  echo
  #cd ${PKG_BUILD} && git submodule update --init --recursive
  # cd ${PKG_BUILD}/externals/vcpkg && git fetch --unshallow
  # sed -e '/add_subdirectory(externals)/d' -i ${PKG_BUILD}/CMakeLists.txt
  sed -i '3i include(../dynarmic/CMakeModules/CreateDirectoryGroups.cmake)' ${PKG_BUILD}/externals/glad/CMakeLists.txt
}

pre_configure_target() {
  PKG_CMAKE_OPTS_TARGET+=" -DYUZU_USE_BUNDLED_VCPKG=OFF \
			   -DENABLE_QT6=ON \
  			   -DYUZU_TESTS=OFF \
			   -DYUZU_USE_EXTERNAL_VULKAN_HEADERS=ON \
			   -DYUZU_USE_BUNDLED_SDL2=OFF \
			   -DYUZU_USE_EXTERNAL_VULKAN_UTILITY_LIBRARIES=ON \
  			   -DCMAKE_BUILD_TYPE=Release \
                           -DCMAKE_CROSSCOMPILING=ON \
                           -DUSE_NATIVE_INSTRUCTIONS=OFF \
                           -DUSE_PRECOMPILED_HEADERS=OFF \
                           -DSTATIC_LINK_LLVM=OFF \
                           -DUSE_SYSTEM_FFMPEG=ON \
                           -DUSE_SYSTEM_CURL=ON \
                           -DUSE_SYSTEM_LIBUSB=ON \
                           -DUSE_LIBEVDEV=ON \
                           -DUSE_SYSTEM_FAUDIO=OFF \
                           -DUSE_SYSTEM_SDL=ON \
			   -DARCHITECTURE=aarch64 \
			   -DARCHITECTURE_aarch64=1"
}

configure_target() {
  export ARCH=aarch64
  export ARCHITECTURE=aarch64
  mkdir -p ${PKG_BUILD}/build
  cd ${PKG_BUILD}/build
  echo "Executing (target): cmake ${CMAKE_GENERATOR_NINJA} ${TARGET_CMAKE_OPTS} ${PKG_CMAKE_OPTS_TARGET} .." | tr -s " "
  echo
  echo "In: ${PWD}"
  echo
  cmake ${CMAKE_GENERATOR_NINJA} ${TARGET_CMAKE_OPTS} ${PKG_CMAKE_OPTS_TARGET} ..
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  mkdir -p ${INSTALL}/usr/share/torzu-sa
  cp -rf ${PKG_BUILD}/bin/* ${INSTALL}/usr/share/torzu-sa

  cp -rf ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin
  chmod 755 ${INSTALL}/usr/bin/*

  mkdir -p ${INSTALL}/usr/config
  cp -rf ${PKG_DIR}/config/${DEVICE}/torzu ${INSTALL}/usr/config
}
