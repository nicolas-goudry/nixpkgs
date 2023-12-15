{ appimageTools, fetchurl, lib, stdenv }:

let
  pname = "kDrive";
  version = "3.5.7.20240124";

  srcs = {
    x86_64-linux = fetchurl {
      url = "https://download.storage.infomaniak.com/drive/desktopclient/kDrive-${version}-amd64.AppImage";
      sha256 = "sha256-q5mqklLZ58YT0qQkfTaKY2mSYGK1Stfduxqzbx1ZHUs=";
    };

    aarch64-linux = fetchurl {
      url = "https://download.storage.infomaniak.com/drive/desktopclient/kDrive-${version}-arm64.AppImage";
      #sha256 = ""; # TODO
    };

    x86_64-darwin = fetchurl {
      url = "https://download.storage.infomaniak.com/drive/desktopclient/kDrive-${version}.pkg";
      #sha256 = ""; # TODO
    };
  };

  src = srcs.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  meta = with lib; {
    description = "kDrive desktop synchronization client.";
    homepage = "https://www.infomaniak.com/kdrive";
    license = licenses.gpl3Plus;
    platforms = builtins.attrNames srcs;
    maintainers = [ maintainers.nicolas-goudry ];
    mainProgram = "kDrive";
  };

  contents = appimageTools.extractType2 { inherit pname version src; };

  linux = appimageTools.wrapType2 {
    inherit pname version src meta;

    multiArch = false;
    extraPkgs = pkgs: (appimageTools.defaultFhsEnvArgs.multiPkgs pkgs) ++ (with pkgs; [
      alsa-lib
      brotli
      curl
      cyrus_sasl
      dbus
      e2fsprogs
      expat
      gmp
      freetype
      fontconfig
      gcc-unwrapped
      glib
      glibc
      gnutls
      heimdal
      icu66
      keyutils
      libffi
      libgcrypt
      libgpg-error
      libidn2
      libjpeg
      libkrb5
      libpng
      libpsl
      libsecret
      libselinux
      libssh
      libtasn1
      libunistring
      libxcrypt-legacy
      libxkbcommon
      libxml2
      log4cplus
      lz4
      nettle
      nghttp2
      nspr
      nss
      openldap
      openssl
      p11-kit
      pcre2
      poco
      qt6.full
      rtmpdump
      sentry-native
      sqlite
      systemd
      util-linux
      xorg.libxcb
      xorg.libxkbfile
      xorg.libxshmfence
      xorg.libX11
      xorg.libXcomposite
      xorg.libXdamage
      xorg.libXext
      xorg.libXfixes
      xorg.libXrandr
      xorg.libXrender
      xorg.libXtst
      xxHash
      xz
      zlib
    ]);

    extraInstallCommands = ''
      mv $out/bin/${pname}-${version} $out/bin/${pname}
      install -m 444 -D ${contents}/kDrive_client.desktop -t $out/share/applications
      cp -r ${contents}/usr/share/icons $out/share
    '';
  };

  darwin = stdenv.mkDerivation {
    inherit pname version src meta;

    dontBuild = true;

    unpackPhase = ''
      7z x $src
      bsdtar -xf Payload~
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin
      install -Dm755 usr/local/bin/kdrive -t $out/bin

      runHook postInstall
    '';
  };
in
if stdenv.isDarwin
then darwin
else linux
