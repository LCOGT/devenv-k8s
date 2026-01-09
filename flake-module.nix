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
    packages = {
      copier = pkgs.copier;
    };

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
        ./deploy.nix
        ./local-cluster
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
        pkgs.copier
      ] ++ localFlake.withSystem system ({self', ...}: [
        self'.packages.kpt
        self'.packages.octopilot
      ]);

      enterShell = ''
        export SHELL=${pkgs.bashInteractive}/bin/bash
      '';

      scripts.kustomize-build-manifest.exec = ''
        set -ex
        mkdir -p .build
        kustomize build -o .build/manifest.yaml
      '';

      scripts.skaffold.exec = localFlake.withSystem system({self', ...}: ''
        pushd "$DEVENV_ROOT" > /dev/null
        ${self'.packages.skaffold}/bin/skaffold "$@"
        ret=$?
        popd > /dev/null
        exit $ret
      '');


    };
  };
}
