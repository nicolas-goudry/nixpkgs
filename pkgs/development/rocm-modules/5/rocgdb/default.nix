{
  lib,
  stdenv,
  fetchFromGitHub,
  rocmUpdateScript,
  pkg-config,
  texinfo,
  bison,
  flex,
  zlib,
  elfutils,
  gmp,
  ncurses,
  expat,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rocgdb";
  version = "5.7.1";

  src = fetchFromGitHub {
    owner = "ROCm";
    repo = "ROCgdb";
    rev = "rocm-${finalAttrs.version}";
    hash = "sha256-TlT7vvTrVd7P6ilVnWIG5VIrjTleFgDezK/mudBV+xE=";
  };

  nativeBuildInputs = [
    pkg-config
    texinfo # For makeinfo
    bison
    flex
  ];

  buildInputs = [
    zlib
    elfutils
    gmp
    ncurses
    expat
  ];

  # `-Wno-format-nonliteral` doesn't work
  env.NIX_CFLAGS_COMPILE = "-Wno-error=format-security";

  passthru.updateScript = rocmUpdateScript {
    name = finalAttrs.pname;
    owner = finalAttrs.src.owner;
    repo = finalAttrs.src.repo;
  };

  meta = with lib; {
    description = "ROCm source-level debugger for Linux, based on GDB";
    homepage = "https://github.com/ROCm/ROCgdb";
    license = with licenses; [
      gpl2
      gpl3
      bsd3
    ];
    teams = [ teams.rocm ];
    platforms = platforms.linux;
    broken = versionAtLeast finalAttrs.version "6.0.0";
  };
})
