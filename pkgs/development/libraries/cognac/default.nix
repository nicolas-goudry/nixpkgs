{
  lib
  , stdenv
  , fetchFromGitHub
  , curl
  , jq
  , json_c
  , json-search
  , pkg-config
  , yq
}:

stdenv.mkDerivation rec {
  pname = "cognac";
  version = "unstable-2024-02-05";

  src = fetchFromGitHub {
    owner = "outscale";
    repo = "COGNAC";
    rev = "82bea3f9aed1c83014922688e4fafd778d309c9e";
    hash = "sha256-RmLOk2fBGeB7zloDfdR4lLeiWapXWtj3AGiGa9rH/D8=";
  };

  nativeBuildInputs = [
    curl
    jq
    json_c
    json-search
    pkg-config
    yq
  ];

  meta = with lib; {
    description = "Give Headache, can be powerful";
    homepage = "https://github.com/outscale/COGNAC";
    license = licenses.bsd3;
    maintainers = with maintainers; [ nicolas-goudry ];
    platforms = platforms.all;
  };
}
