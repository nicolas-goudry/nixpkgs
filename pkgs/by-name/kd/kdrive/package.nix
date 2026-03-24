{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  cups,
  extra-cmake-modules,
  libGL,
  libgcrypt,
  libgpg-error,
  libsecret,
  libsysprof-capture,
  libzip,
  log4cplus,
  openssl,
  pkg-config,
  poco,
  qt6,
  sentry-native,
  shared-mime-info,
  sqlite,
  xxHash,
  zlib,
}:

let
  # This is required because kdrive needs the log4cplusConfig.cmake file, which is only generated when built with cmake.
  # Since log4cplus is built with make in nixpkgs, we rebuild it with cmake.
  log4cplus-cmake = log4cplus.overrideAttrs (old: {
    pname = "log4cplus-cmake";

    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ cmake ];

    cmakeFlags = [
      # kDrive uses the unicode version of log4cplus.
      "-DUNICODE=ON"
      # Disable decorated library name so that kDrive can find log4cplus::log4cplus. This avoid having to patch kDrive
      # code to match the decorated name log4cplus::log4cplusU when unicode is enabled.
      "-DLOG4CPLUS_ENABLE_DECORATED_LIBRARY_NAME=OFF"
      # See https://github.com/NixOS/nixpkgs/issues/144170 for why this is needed.
      "-DCMAKE_INSTALL_INCLUDEDIR=include"
      "-DCMAKE_INSTALL_LIBDIR=lib"
    ];
  });
in
stdenv.mkDerivation (finalAttrs: {
  pname = "kdrive";
  version = "3.8.3";

  src = fetchFromGitHub {
    owner = "Infomaniak";
    repo = "desktop-kDrive";
    rev = finalAttrs.version;
    hash = "sha256-JUjMh7vAeqOESd4fhMCq0sChAZRTRC98lgyNH8ARW5M=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    libsysprof-capture
    pkg-config
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    cups
    libGL
    libgcrypt
    libgpg-error
    libsecret
    libzip
    log4cplus-cmake
    openssl
    poco
    qt6.qt5compat
    qt6.qtbase
    qt6.qtnetworkauth
    qt6.qtsvg
    qt6.qttools
    qt6.qtwebchannel
    qt6.qtwebengine
    qt6.qtwebsockets
    sentry-native
    shared-mime-info
    sqlite
    xxHash
    zlib
  ];

  # Patch to disable Sentry's crashpad handler. Nixpkgs' sentry-native uses breakpad handler (which should be fine).
  patches = [ ./kdrive-CMakeLists.txt.patch ];

  # "Hack" to have SYSCONFDIR point to the Nix store path thanks to ${outputBin}. This is needed because kDrive
  # installs sentry's shared library and sync-exclude.lst at this location. If unset, cmake will attempt to install
  # those at fs root, which is not permitted.
  preConfigure = ''
    prependToVar cmakeFlags "-DSYSCONFDIR=''${!outputBin}"
  '';

  cmakeFlags = [
    # Prevent dev warnings from ECM.
    "-Wno-dev"
    # Original options from upstream.
    # NOTE: we explicitly don't set CMAKE_BUILD_TYPE nor CMAKE_INSTALL_PREFIX here since they are already added by
    #       nixpkgs' cmake build environment.
    "-DQT_FEATURE_neon=OFF"
    "-DKDRIVE_THEME_DIR=${finalAttrs.src}/infomaniak"
    # Disables unit tests. Requires cppunit.
    # TODO: enable?
    "-DBUILD_UNIT_TESTS=0"
  ];

  # Prevent compilation error of keychain submodule.
  env.NIX_CFLAGS_COMPILE = "-Wno-error=uninitialized";

  # Move sync-exclude.lst to the bin directory since kDrive fails to start without it at this location.
  postInstall = ''
    mv $out/kDrive/sync-exclude.lst $out/bin
    rm -rf $out/kDrive
  '';

  meta = {
    mainProgram = "kdrive";
    description = "Desktop syncing client for kDrive";
    homepage = "https://github.com/Infomaniak/desktop-kDrive";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ nicolas-goudry ];
    platforms = lib.platforms.all;
  };
})
