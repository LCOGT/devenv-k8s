{ lib, config, ... }:
let
  cfg = config.devenv-k8s.local-cluster;
in {
  options.devenv-k8s.local-cluster = {
    enable = lib.mkEnableOption "Whether to setup the local development K8s cluster";
  };
  config = lib.mkIf cfg.enable {

    enterShell = ''
      export KUBECONFIG=~/.kube/config-devenv-k8s
      local-cluster-up || exit 1
    '';

    scripts = {
      local-cluster-up.exec = ''
        set -ex
        ctlptl apply -f "${./local-cluster-registry.yaml}" -f "${./local-cluster.yaml}"
        kubectl cluster-info
      '';

      local-cluster-down.exec = ''
        set -ex
        ctlptl delete -f "${./local-cluster.yaml}"
      '';

      local-cluster-reg-down.exec = ''
        set -ex
        ctlptl delete -f "${./local-cluster-registry.yaml}"
      '';
    };
  };
}
