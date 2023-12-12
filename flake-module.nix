localFlake:
{ inputs, ... }:
{
  imports = [
    inputs.devenv.flakeModule
  ];

  perSystem = { inputs', config, pkgs, ... }: {
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

        config.packages.kpt
        config.packages.octopilot
      ];
    };
  };
}
