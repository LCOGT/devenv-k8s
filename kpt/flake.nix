{
  description = "Automate Kubernetes Configuration Editing";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    kpt = {
      type = "github";
      owner = "kptdev";
      repo = "kpt";
      ref = "v1.0.0-beta.48";
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
          pname = "kpt";

          version = original.inputs.kpt.ref;

          src = inputs.kpt;

          subPackages = [ "." ];

          ldflags = [ "-s" "-w" "-X github.com/GoogleContainerTools/kpt/run.version=${version}-g${inputs.kpt.shortRev}" ];

          vendorHash = "sha256-NQ/JqXokNmr8GlIhqTJb0JFyU2mAEXO+2y5vI79TuX4=";

          meta = {
            inherit (original) description;
            homepage = "https://github.com/kptdev/kpt";
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
