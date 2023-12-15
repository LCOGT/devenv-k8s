localFlake:
{ inputs, ... }:
{
  imports = [
    inputs.devenv.flakeModule
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
        pkgs.skaffold
        pkgs.kubeseal
        pkgs.kubernetes-helm
        pkgs.kustomize
        pkgs.jq
      ] ++ localFlake.withSystem system ({self', ...}: [
        self'.packages.kpt
        self'.packages.octopilot
      ]);
    };
  };
}
