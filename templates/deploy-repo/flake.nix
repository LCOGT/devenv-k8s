{
  description = "GitOps deploy repo";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    devenv-k8s.url = "github:LCOGT/devenv-k8s";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.devenv-k8s.flakeModules.default
      ];

      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];

      perSystem = { lib, config, ... }: {

        # Enable these as you see fit
        config.devenv.shells.default = {
          pre-commit.hooks.kustomize-build-staging.enable = lib.mkForce false;
          pre-commit.hooks.kustomize-build-prod.enable = lib.mkForce false;
        };
      };
    };
}
