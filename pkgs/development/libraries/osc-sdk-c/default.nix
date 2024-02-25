{
  lib
  , stdenv
  , fetchFromGitHub
  , curl
  , json_c
  , jsoncpp
  , pkg-config
}:

stdenv.mkDerivation rec {
  pname = "osc-sdk-c";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "outscale";
    repo = "osc-sdk-C";
    rev = "v${version}";
    hash = "sha256-30kD2V1x6guWZ8KHvNx3zyHmhq+Ew8Y/+M6+SlpYE1k=";
    fetchSubmodules = true;
  };

  doCheck = true;

  nativeBuildInputs = [
    curl
    json_c
    pkg-config
  ];

  buildFlags = [
    "osc_sdk.a"
  ];

  nativeCheckInputs = [
    jsoncpp
  ];

  checkTarget = "examples";

  installPhase = ''
    mkdir -p $out/lib $out/include

    cp osc_sdk.a $out/lib
    cp osc_sdk.h $out/include
  '';

  meta = with lib; {
    description = "C SDK for Outscale";
    homepage = "https://github.com/outscale/osc-sdk-C";
    license = licenses.bsd3;
    maintainers = with maintainers; [ nicolas-goudry ];
    mainProgram = "osc-sdk-c";
    platforms = platforms.all;
  };
}
