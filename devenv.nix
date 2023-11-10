{ pkgs, ... }:

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
  ];

  # See full reference at https://devenv.sh/reference/options/
}
