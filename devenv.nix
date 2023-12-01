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

  scripts.skaffold-builder-buildx.exec = ''
    set -ex

    args=""

    if test "$PUSH_IMAGE" = true; then
      args+="--push "
    fi

    if test -n "$PLATFORMS"; then
      args+="--platform $PLATFORMS "
    fi

    docker buildx build "$BUILD_CONTEXT" --tag $IMAGE $args $SKAFFOLD_BUILDX_ARGS
  '';

  # See full reference at https://devenv.sh/reference/options/
}
