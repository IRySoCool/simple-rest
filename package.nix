{ mkDerivation, aeson, base, containers, lib, monad-logger, mtl
, optparse-generic, polysemy, polysemy-plugin, servant
, servant-server, text, warp
}:
mkDerivation {
  pname = "my-project";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    aeson base containers monad-logger mtl optparse-generic polysemy
    polysemy-plugin servant servant-server text warp
  ];
  license = lib.licenses.wtfpl;
}
