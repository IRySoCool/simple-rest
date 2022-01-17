{ mkDerivation, aeson, base, bytestring, containers, lib
, monad-logger, mtl, optparse-generic, persistent
, persistent-postgresql, persistent-template, polysemy
, polysemy-plugin, profunctors, resource-pool, servant
, servant-server, text, time, vector, warp
}:
mkDerivation {
  pname = "simple-rest";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    aeson base bytestring containers monad-logger mtl optparse-generic
    persistent persistent-postgresql persistent-template polysemy
    polysemy-plugin profunctors resource-pool servant servant-server
    text time vector warp
  ];
  license = lib.licenses.wtfpl;
}
