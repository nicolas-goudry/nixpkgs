{
  appimageTools
  , fetchurl
  , lib
  , stdenv
  , wrapQtAppsHook
  , gcc-unwrapped
  , glib
  , libsecret
  , poco
  , qt6
  , qtbase
  , sentry-native
  , sqlite
  , xxHash
  , zlib
}:

with lib;

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

  meta = {
    description = "kDrive desktop synchronization client.";
    homepage = "https://www.infomaniak.com/kdrive";
    license = licenses.gpl3Plus;
    platforms = builtins.attrNames srcs;
    maintainers = [ maintainers.nicolas-goudry ];
    mainProgram = "kDrive";
  };

  contents = appimageTools.extract { inherit pname version src; };

  linux = stdenv.mkDerivation rec {
    inherit pname version src meta;

    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;
    # Avoid auto-wrap to set rpath
    dontWrapQtApps = true;

    buildInputs = [ qtbase ];
    nativeBuildInputs = [ wrapQtAppsHook ];
    libPath = makeLibraryPath [
      # kDrive dependencies
      gcc-unwrapped
      glib
      libsecret
      poco
      qt6.qtbase
      sentry-native
      sqlite
      xxHash
      zlib
      # kDrive_client dependencies
      qt6.qtsvg
      qt6.qtwebengine
    ];

    installPhase = ''
      runHook preInstall

      # Copy top-level stuff
      for dir in bin resources translations; do
        mkdir -p $out/$dir
        cp -R ${contents}/usr/$dir/* $out/$dir
      done

      # Copy some content from share directory
      for dir in applications icons kDrive_client mime; do
        mkdir -p $out/share/$dir
        cp -R ${contents}/usr/share/$dir/* $out/share/$dir
      done

      # Keep liblog4cplusU since it is not available in nixpkgs
      mkdir -p $out/lib
      cp -R ${contents}/usr/lib/liblog4cplusU.so.9 $out/lib

      runHook postInstall
    '';

    postFixup = ''
      pushd $out/bin
      for file in kDrive kDrive_client; do
        patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $file
        patchelf --set-rpath ${libPath}:$out/lib $file || true
      done
      popd

      wrapQtApp $out/bin/kDrive
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
