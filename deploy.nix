{ lib, config, ... }:
let
  cfg = config.devenv-k8s.deploy;
in {
  options.devenv-k8s.deploy = {
    staging = {
      enable = lib.mkEnableOption "Enable staging environment";
      git-hooks = lib.mkOption {
        type = lib.types.attrs;
        description = "Git hooks to run for staging environment";
        default = {
          kustomize-build-staging = {
            enable = true;
            name = "Build staging Kustomization";
            pass_filenames = false;
            raw.always_run = true;
            entry = "kustomize build staging/ --output output/staging/manifest.yaml";
          };
        };
      };
    };
    prod = {
      enable = lib.mkEnableOption "Enable production environment";
      git-hooks = lib.mkOption {
        type = lib.types.attrs;
        description = "Git hooks to run for prod environment";
        default = {
          kustomize-build-prod = {
            enable = true;
            name = "Build prod Kustomization";
            pass_filenames = false;
            raw.always_run = true;
            entry = "kustomize build prod/ --output output/prod/manifest.yaml";
          };
        };
      };
    };
  };
  config = {
    git-hooks.hooks = lib.mkMerge [
      {
        # devenv will only modify .pre-commit-config.yaml if at-least one hook
        # is enabled. This is a hack to ensure that if the other two are disabled,
        # they are removed from that file.
        no-op = {
          enable = true;
          name = "No Op (this does nothing)";
          pass_filenames = false;
          raw.always_run = true;
          entry = "true";
        };
      }
      (lib.mkIf cfg.staging.enable cfg.staging.git-hooks)
      (lib.mkIf cfg.prod.enable cfg.prod.git-hooks)
    ];
  };
}
