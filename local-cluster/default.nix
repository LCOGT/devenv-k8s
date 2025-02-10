{ lib, config, ... }:
let
  cfg = config.devenv-k8s.local-cluster;
in {
  options.devenv-k8s.local-cluster = {
    enable = lib.mkEnableOption "Setup the local development K8s cluster";
    dashboard = {
      disable = lib.mkEnableOption "Disable K8s dashboard";
    };
  };
  config = lib.mkIf cfg.enable {

    enterShell = ''
      export KUBECONFIG=~/.kube/config-devenv-k8s
      local-cluster-up || exit 1

      ${if !cfg.dashboard.disable then ''
        echo ""
        echo "K8s dashboard running at https://k8s.local.lco.earth"
        echo ""
      '' else ""}
    '';

    tasks = {
      "devenv-k8s:local-cluster:setupNginxIngress" = {
        exec = "local-cluster-nginx-ingress-up";
        before = [ "devenv:enterShell" ];
      };

      "devenv-k8s:local-cluster:updateLocalLcoEarthCert" = lib.mkIf (!cfg.dashboard.disable) {
        exec = "local-cluster-update-local-lco-earth-cert";
        before = [ "devenv-k8s:local-cluster:setupNginxIngress" ];
      };

      "devenv-k8s:local-cluster:setupK8sDashboard" = lib.mkIf (!cfg.dashboard.disable) {
        exec = "local-cluster-k8s-dashboard-up";
        before = [ "devenv-k8s:local-cluster:setupNginxIngress" ];
      };

    };

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

      local-cluster-nginx-ingress-up.exec = ''
        set -ex -o pipefail
        kustomize build "${./ingress-nginx}" | kubectl apply -f -
      '';

      local-cluster-nginx-ingress-down.exec = ''
        set -ex -o pipefail
        kustomize build "${./ingress-nginx}" | kubectl delete -f -
      '';

      local-cluster-k8s-dashboard-up.exec = ''
        set -ex -o pipefail
        kustomize build "${./dash}" | kubectl apply -f -
      '';

      local-cluster-k8s-dashboard-down.exec = ''
        set -ex -o pipefail
        kustomize build "${./dash}" | kubectl delete -f -
      '';

      local-cluster-update-local-lco-earth-cert.exec = ''
        set -ex
        kubectl apply -f https://raw.githubusercontent.com/LCOGT/local-lco-earth-cert/refs/heads/main/tls.yaml
      '';
    };
  };
}
