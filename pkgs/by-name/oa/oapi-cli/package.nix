{
  lib
  , stdenv
  , fetchFromGitHub
  , curl
  , json_c
  , osc-sdk-c
}:

stdenv.mkDerivation rec {
  pname = "oapi-cli";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "outscale";
    repo = "oapi-cli";
    rev = "v${version}";
    hash = "sha256-h6MBOFHFDOVan2ietbZp0dMg1LaYN1v8UnNEy7O+KUE=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    curl
    json_c
    osc-sdk-c
  ];

  buildFlags = [
    "main.c"
    "main-helper.h"
    "oapi-cli-completion.bash"
  ];

  #patches = [
    #./Makefile.patch
  #];

  #postPatch = ''
    #substituteInPlace main.c osc_sdk.c --replace "json.h" "json_c/json.h"
  #'';

  meta = with lib; {
    description = "Outscale API CLI";
    homepage = "https://github.com/outscale/oapi-cli";
    license = licenses.bsd3;
    maintainers = with maintainers; [ nicolas-goudry ];
    mainProgram = "oapi-cli";
    platforms = platforms.all;
  };
}
