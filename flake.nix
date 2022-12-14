{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    naersk.url = "github:nix-community/naersk";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, flake-utils, naersk, nixpkgs}:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = (import nixpkgs) {
          inherit system;        
        };
        version = "0.3.1";
        naersk' = pkgs.callPackage naersk {};
      in rec {
        packages = {
          default = naersk'.buildPackage {
            pname = "btc-rpc-proxy";
            inherit version;
            src = ./.;
          };
          proxy-service = pkgs.substituteAll {
            name = "btc-rpc-proxy.service";
            src = ./systemd/btc-rpc-proxy.service;
            proxy = self.packages.${system}.default;
          };
          portable =
            let proxy = self.packages.${system}.default;
            in pkgs.portableService {
              inherit (proxy) version;
              inherit (proxy) pname;
              description = "BTC RPC Proxy";
              units = [ self.packages.${system}.proxy-service ];
            };
        };
      });
}
