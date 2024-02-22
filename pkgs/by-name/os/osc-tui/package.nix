{
  lib
  , python3
  , fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "osc-tui";
  version = "23.12.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "outscale";
    repo = "osc-tui";
    rev = "v${version}";
    hash = "sha256-WG2S0o0oA41U8ofN0cdKCVT4hdaSBBW2pVtmxl2QfBc=";
  };

  nativeBuildInputs = [
    python3.pkgs.setuptools
  ];

  propagatedBuildInputs = with python3.pkgs; [
    osc-diagram
    osc-sdk-python
    oscscreen
    pyperclip
    requests
  ];

  doCheck = false;

  meta = with lib; {
    description = "TUI client for Outscale API";
    homepage = "https://github.com/outscale/osc-tui";
    license = licenses.bsd3;
    maintainers = with maintainers; [ nicolas-goudry ];
    mainProgram = "osc-tui";
  };
}
