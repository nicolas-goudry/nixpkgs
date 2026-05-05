{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Minimal,
  tinyxxd,
  darwin,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "elfuse";
  version = "0-unstable-2026-05-05";

  src = fetchFromGitHub {
    owner = "sysprog21";
    repo = "elfuse";
    rev = "a49ea1deea6c2bf8c05663686a3f93408c74fad0";
    hash = "sha256-PXiw4tWE5d/DlMhKyn3E556thAUy2Nw3PlnvGbhuCeA=";
  };

  patches = [
    # ./fix-id.patch
  ];

  nativeBuildInputs = [
    darwin.sigtool
    python3Minimal
    tinyxxd
  ];
  buildFlags = [ "elfuse" ];

  # doCheck = true;
  nativeCheckInputs = [
    python3Minimal
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -Dm0755 build/elfuse $out/bin

    runHook postInstall
  '';

  meta = {
    description = "Run Arm64/Linux ELF binaries on macOS Apple Silicon";
    homepage = "https://github.com/sysprog21/elfuse";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ nicolas-goudry ];
    mainProgram = "elfuse";
    platforms = [ "aarch64-darwin" ];
  };
})
