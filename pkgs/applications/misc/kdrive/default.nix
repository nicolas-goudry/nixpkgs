{
  lib
  , stdenv
  , fetchFromGitHub
  , cmake
  , glib
  , libgcrypt
  , libGL
  , libgpg-error
  , libsecret
  , libxkbcommon
  , log4cplus
  , openssl_3_3
  , pkg-config
  , poco
  , qt6
  , sentry-native
  , shared-mime-info
  , sqlite
  , vulkan-headers
  , xxHash
  , zlib
}:

stdenv.mkDerivation rec {
  pname = "kDrive";
  version = "3.6.1";

  src = fetchFromGitHub {
    owner = "infomaniak";
    repo = "desktop-kDrive";
    rev = version;
    hash = "sha256-Aq7/cYIntVglfaAgKJsbfvTzwPcSWQkR4O0Sc+puhpw=";
  };

  buildInputs = [
    cmake
    glib
    libgcrypt
    libGL
    libgpg-error
    libsecret
    libxkbcommon
    # This is required because kdrive needs the log4cplusConfig.cmake file, which is only generated when built with cmake
    # Since log4cplus is built with make in nixpkgs, we rebuild it with cmake
    # See this issue for why the preInstall is needed: https://github.com/NixOS/nixpkgs/issues/144170
    (log4cplus.overrideAttrs(_: {
      nativeBuildInputs = [ cmake ];
      patches = [ ./log4cplus-CMakeLists.txt.patch ];
      /* preInstall = ''
        substituteInPlace ./lib/pkgconfig/log4cplus.pc --replace-fail "''${prefix}/" ""
      ''; */
    }))
    # log4cplus
    openssl_3_3
    pkg-config
    poco
    qt6.qt5compat
    qt6.qtbase
    qt6.qtsvg
    qt6.qttools
    qt6.qtwayland
    qt6.qtwebengine
    shared-mime-info
    sentry-native
    sqlite
    vulkan-headers
    xxHash
    zlib
  ];

  nativeBuildInputs = [ qt6.wrapQtAppsHook ];

  cmakeFlags = [
    "-DKDRIVE_THEME_DIR=${src}/infomaniak"
  ];

  meta = {
    description = "Desktop Syncing Client for kDrive";
    homepage = "https://github.com/infomaniak/desktop-kDrive";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib; [ maintainers.nicolas-goudry ];
    mainProgram = "kDrive";
  };
}
