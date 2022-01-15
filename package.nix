{ mkDerivation, base, lib, polysemy, polysemy-plugin, turtle }:
mkDerivation {
  pname = "my-project";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    base polysemy polysemy-plugin turtle
  ];
  license = lib.licenses.wtfpl;
}
