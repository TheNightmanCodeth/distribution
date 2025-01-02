# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="torzu-sa"
PKG_VERSION="02cfee3f184e6fdcc3b483ef399fb5d2bb1e8ec7"
PKG_SITE="https://notabug.org/litucks/torzu"
PKG_URL="https://notabug.org/litucks/torzu"
PKG_LICENSE="GPLv3"
PKG_TOOLCHAIN="cmake"
PKG_DEPENDS_TARGET="toolchain linux glibc systemd pulseaudio mesa xwayland libevdev curl ffmpeg libpng zlib glew-cmake SDL2 qt6 llvm"
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

pre_configure_target() {
  PKG_CMAKE_OPTS_TARGET+=" -DYUZU_USE_BUNDLED_VCPKG=ON \
						   -DENABLE_QT6=ON \
  						   -DYUZU_TESTS=OFF \
  						   -DCMAKE_BUILD_TYPE=Release \
                           -DCMAKE_CROSSCOMPILING=ON \
                           -DBUILD_SHARED_LIBS=OFF \
                           -DUSE_NATIVE_INSTRUCTIONS=OFF \
                           -DUSE_PRECOMPILED_HEADERS=OFF \
                           -DSTATIC_LINK_LLVM=OFF \
                           -DUSE_SYSTEM_FFMPEG=ON \
                           -DUSE_SYSTEM_CURL=ON \
                           -DUSE_SYSTEM_LIBUSB=ON \
                           -DUSE_LIBEVDEV=ON \
                           -DUSE_SYSTEM_FAUDIO=OFF \
                           -DUSE_SYSTEM_SDL=ON"
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
