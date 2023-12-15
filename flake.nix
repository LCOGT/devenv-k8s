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
    flake-parts.lib.mkFlake { inherit inputs; } ({ withSystem, flake-parts-lib, ...}:
    let
      inherit (flake-parts-lib) importApply;
      flakeModules.default = importApply ./flake-module.nix { inherit withSystem; };
    in
    {
      imports = [
        flakeModules.default
      ];

      flake = {
        inherit flakeModules;
      };

      systems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      perSystem = { inputs', ...}: {

        packages = {
          kpt = inputs'.kpt.packages.default;
          octopilot = inputs'.octopilot.packages.default;
        };

      };
    });
}
