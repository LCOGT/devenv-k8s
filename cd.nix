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

    scripts.cd-update-staging.exec = ''
      set -ex

      if test -z "$1"; then
        echo "first argument should be an absolute path to the skaffold build output"
        exit 1
      fi

      if test -z "$2"; then
        echo "second argument should be the git commit hash"
        exit 1
      fi

      pushd $DEVENV_ROOT

      pushd staging/

      kpt pkg update --strategy force-delete-replace base@$2

      if test -f "$1"; then
        pushd cd-set-images
        sh -xe <(cat $1 | jq -r '.builds[] | "kustomize edit set image \(.imageName)=\(.tag)"')
        popd
      fi
      popd

      kustomize build staging/ --output output/staging/manifest.yaml
      popd
    '';

    scripts.cd-update-prod.exec = ''
      set -ex

      if test -z "$1"; then
        echo "first argument should be git commit hash of staging"
        exit 1
      fi

      pushd $DEVENV_ROOT

      kpt pkg update --strategy force-delete-replace prod/base@$2
      kpt pkg update --strategy force-delete-replace prod/cd-set-images@$2

      kustomize build prod/ --output output/prod/manifest.yaml
      popd
    '';
  };
}
