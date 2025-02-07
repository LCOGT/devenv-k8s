localFlake:
{ ... }:
let
  devenvModule = { ... }@args: localFlake.inputs.devenv.flakeModule (
    args // {
      inputs = {
        inherit (localFlake.inputs) nix2container mk-shell-bin;
      } // args.inputs;
    }
  );
in
{
  imports = [
    devenvModule
  ];

  perSystem = { system, pkgs, ... }: {

    devenv.shells.default = let
      kustomize = pkgs.kustomize.overrideAttrs (prevAttrs: {
        postPatch = ''
          substituteInPlace kustomize/commands/build/flagenableplugins.go \
            --replace 'false,' 'true,'
        '';
      });
    in {
      name = "devenv-k8s";

      imports = [
        ./skaffold-builder.nix
        ./cd.nix
        ./local-cluster.nix
      ];

      # https://devenv.sh/packages/
      packages = [
        pkgs.bashInteractive
        pkgs.git
        pkgs.kubectl
        pkgs.kind
        pkgs.kubeseal
        pkgs.kubernetes-helm
        kustomize
        pkgs.jq
        pkgs.ctlptl
      ] ++ localFlake.withSystem system ({self', ...}: [
        self'.packages.kpt
        self'.packages.octopilot
        self'.packages.skaffold
      ]);

      enterShell = ''
        export SHELL=${pkgs.bashInteractive}/bin/bash
      '';
    };
  };
}
