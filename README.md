# simple-rest

---
A simple rest API backend built with Nix, Servant, Postgres, etc.

Nix, cabal2nix, cabal-install is required for this project. And we are using
docker to create postgres db for testing.

To add a haskell dependency, simply add it under build-depends in simple-rest.cabal, and then update package.nix by:
```sh
cabal2nix . > package.nix
```

Start the app by running ```cabal run simple-rest``` in nix-shell.

To setup the postgres database, run ```docker-compose up -d``` in this directory.

To update hie.yaml, run ```gen-hie > hie.yaml``` in nix-shell.

we may pass options to the executable to override some settings on this app.
```sh
[nix-shell:~/simple-rest]$ ./simple-rest --help
Application

Usage: simple-rest [--port INT] [--size INT] [--connStr TEXT]

Available options:
  -h,--help                Show this help text
  --port INT               Port number for the app
  --size INT               Database Connection pool size
  --connStr TEXT           Database Connection string
```