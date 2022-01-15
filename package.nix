{ mkDerivation, aeson, base, lib, optparse-generic, polysemy
, polysemy-plugin, servant, servant-server
}:
mkDerivation {
  pname = "my-project";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    aeson base optparse-generic polysemy polysemy-plugin servant
    servant-server
  ];
  license = lib.licenses.wtfpl;
}
