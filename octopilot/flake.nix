{
  description = "Automate your Gitops workflow, by automatically creating/merging GitHub Pull Requests ";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    octopilot = {
      type = "github";
      owner = "dailymotion-oss";
      repo = "octopilot";
      ref = "v1.6.0";
      flake = false;
    };
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      perSystem = { config, self', inputs', pkgs, system, ... }: {
        # Per-system attributes can be defined here. The self' and inputs'
        # module parameters provide easy access to attributes of the same
        # system.

        packages.default = let
          original = import "${inputs.self}/flake.nix";
        in pkgs.buildGoModule rec {
          pname = "octopilot";

          version = original.inputs.octopilot.ref;

          src = inputs.octopilot;

          subPackages = [ "." ];

          ldflags = [
            "-s" "-w"
            "-X main.buildVersion=${version}-g${inputs.octopilot.shortRev}"
            "-X main.buildCommit=${inputs.octopilot.rev}"
            "-X main.buildDate=${inputs.octopilot.lastModifiedDate}"
          ];

          vendorHash = null;

          meta = {
            inherit (original) description;
            homepage = "https://github.com/dailymotion-oss/octopilot";
          };

        };
      };
      flake = {
        # The usual flake attributes can be defined here, including system-
        # agnostic ones like nixosModule and system-enumerating ones, although
        # those are more easily expressed in perSystem.

      };
    };
}
