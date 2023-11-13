{ pkgs, lib, ... }:

let
 kpt = import ./kpt.nix { inherit pkgs lib; };
 octopilot = import ./octopilot.nix { inherit pkgs lib; };
in
{
  # https://devenv.sh/packages/
  packages = [
    pkgs.git
    pkgs.kubectl
    pkgs.kind
    pkgs.skaffold
    pkgs.kubeseal
    pkgs.kubernetes-helm
    pkgs.kustomize
    kpt
    octopilot
  ];

  # See full reference at https://devenv.sh/reference/options/
}
