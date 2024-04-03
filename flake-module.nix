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
        pkgs.kubeseal
        pkgs.kubernetes-helm
        pkgs.kustomize
        pkgs.jq
        pkgs.ctlptl
      ] ++ localFlake.withSystem system ({self', ...}: [
        self'.packages.kpt
        self'.packages.octopilot
        self'.packages.skaffold
      ]);
    };
  };
}
