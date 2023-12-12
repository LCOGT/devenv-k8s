{
  description = "A devenv with common tools needed for K8s, GitOps, etc.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    devenv.url = "github:cachix/devenv";
    nix2container.url = "github:nlewo/nix2container";
    nix2container.inputs.nixpkgs.follows = "nixpkgs";
    mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";

    kpt = {
      url = "path:kpt";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    octopilot = {
      url = "github:dailymotion-oss/octopilot";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  nixConfig = {
    extra-trusted-public-keys = ''
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      lco-public.cachix.org-1:zSmLK7CkAehZ7QzTLZKt+5Y26Lr0w885GUB4GlT1SCg=
    '';

    extra-substituters = ''
      https://devenv.cachix.org
      https://lco-public.cachix.org
    '';
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.devenv.flakeModule
      ];

      systems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      perSystem = { config, self', inputs', pkgs, system, lib, ... }: {
        # Per-system attributes can be defined here. The self' and inputs'
        # module parameters provide easy access to attributes of the same
        # system.

        packages.kpt = inputs'.kpt.packages.default;
        packages.octopilot = inputs'.octopilot.packages.default;

        devenv.shells.default = {
          name = "devenv-k8s";

          imports = [
            ./skaffold-builder.nix
            ./cd.nix
          ];

          # https://devenv.sh/packages/
          packages = [
            pkgs.git
            pkgs.kubectl
            pkgs.kind
            pkgs.skaffold
            pkgs.kubeseal
            pkgs.kubernetes-helm
            pkgs.kustomize
            pkgs.jq

            inputs'.kpt.packages.default
            inputs'.octopilot.packages.default
          ];

          # See full reference at https://devenv.sh/reference/options/

        };

      };
      flake = {
        # The usual flake attributes can be defined here, including system-
        # agnostic ones like nixosModule and system-enumerating ones, although
        # those are more easily expressed in perSystem.

      };
    };
}
