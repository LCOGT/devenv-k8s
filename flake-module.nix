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

      devenv.root =
        let
          devenvRootFileContent = builtins.readFile localFlake.inputs.devenv-root.outPath;
        in
        pkgs.lib.mkIf (devenvRootFileContent != "") devenvRootFileContent;

      imports = [
        ./skaffold-builder.nix
        ./cd.nix
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
