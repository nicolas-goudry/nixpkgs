{
  lib,
  buildPythonPackage,
  fetchPypi,
  pythonAtLeast,

  # build-system
  setuptools,
  setuptools-scm,

  # tests
  pytestCheckHook,
  simplejson,
}:

buildPythonPackage rec {
  pname = "jsonpickle";
  version = "4.0.2";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-PmULmFOtzaudnWKohBK2026aWbpCOwHKzwzU7oBzOso=";
  };

  build-system = [
    setuptools
    setuptools-scm
  ];

  preCheck = ''
    rm pytest.ini
  '';

  nativeCheckInputs = [
    pytestCheckHook
    simplejson
  ];

  disabledTests = lib.optionals (pythonAtLeast "3.12") [
    # imports distutils
    "test_thing_with_submodule"
  ];

  meta = with lib; {
    description = "Python library for serializing any arbitrary object graph into JSON";
    downloadPage = "https://github.com/jsonpickle/jsonpickle";
    homepage = "http://jsonpickle.github.io/";
    license = licenses.bsd3;
  };
}
