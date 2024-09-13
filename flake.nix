{
  description = "A devenv with common tools needed for K8s, GitOps, etc.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    devenv.url = "github:cachix/devenv";
    nix2container.url = "github:nlewo/nix2container";
    nix2container.inputs.nixpkgs.follows = "nixpkgs";
    mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";

    kpt = {
      url = "github:LCOGT/devenv-k8s?dir=kpt";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    skaffold = {
      url = "github:jashandeep-sohi/skaffold";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    octopilot = {
      url = "github:jashandeep-sohi/octopilot/fix/commit-with-api";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    deploy-repo-template =  {
      url = "git+https://github.com/LCOGT/deploy-repo-template.git";
      flake = false;
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://devenv.cachix.org"
      "https://lco-public.cachix.org"
    ];

    extra-trusted-public-keys = [
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "lco-public.cachix.org-1:zSmLK7CkAehZ7QzTLZKt+5Y26Lr0w885GUB4GlT1SCg="
    ];
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } ({ withSystem, flake-parts-lib, ...}:
    let
      inherit (flake-parts-lib) importApply;
      flakeModules.default = importApply ./flake-module.nix { inherit inputs withSystem; };
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
          skaffold = inputs'.skaffold.packages.default;
        };

      };

      flake = {
        templates = {

          app-repo = {
            path = ./templates/app-repo;
            description = "Application source repo";
            welcomeText = ''
              Add the following to `.gitignore`:

              ```sh
                echo .devenv >> .gitignore
                echo .pre-commit-config.yaml >> .gitignore
              ```
            '';
          };

          deploy-repo = {
            path = inputs.deploy-repo-template.outPath;
            description = "GitOps deploy repo";
          };
        };
      };
    });
}
