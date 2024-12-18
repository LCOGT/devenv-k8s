{ config, pkgs, ...}:
{
  config = {
    pre-commit.hooks = {
      kustomize-build-staging = {
        enable = false;
        name = "Ensure staging kustomization output is up to date";
        pass_filenames = false;
        raw.always_run = true;
        entry = "kustomize build staging/ --output output/staging/manifest.yaml";
      };

      kustomize-build-prod = {
        enable = false;
        name = "Ensure prod kustomization output is up to date";
        pass_filenames = false;
        raw.always_run = true;
        entry = "kustomize build prod/ --output output/prod/manifest.yaml";
      };
    };

    scripts.kustomize-build-staging.exec = ''
      set -xe
      pushd $DEVENV_ROOT
      kustomize build staging/ --output output/staging/manifest.yaml
      popd
    '';

    scripts.kustomize-build-prod.exec = ''
      set -xe
      pushd $DEVENV_ROOT
      kustomize build prod/ --output output/prod/manifest.yaml
      popd
    '';
  };
}
