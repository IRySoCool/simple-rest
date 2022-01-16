{ mkDerivation, aeson, base, bytestring, containers, hasql
, hasql-pool, hasql-th, lib, monad-logger, mtl, optparse-generic
, polysemy, polysemy-plugin, profunctors, servant, servant-server
, text, time, tuple, vector, warp
}:
mkDerivation {
  pname = "simple-rest";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    aeson base bytestring containers hasql hasql-pool hasql-th
    monad-logger mtl optparse-generic polysemy polysemy-plugin
    profunctors servant servant-server text time tuple vector warp
  ];
  license = lib.licenses.wtfpl;
}
