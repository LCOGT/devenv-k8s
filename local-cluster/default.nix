{ lib, config, ... }:
let
  cfg = config.devenv-k8s.local-cluster;
in {
  options.devenv-k8s.local-cluster = {
    enable = lib.mkEnableOption "Enable the local development K8s cluster";
    setup.disable = lib.mkEnableOption "Disable setting up the cluster automatically after entering the development shell.";
  };
  config = lib.mkIf cfg.enable (lib.mkMerge [

    {
      enterShell = lib.mkBefore ''
        export KUBECONFIG=~/.kube/config-devenv-k8s
        echo "KUBECONFIG=$KUBECONFIG"
      '';

      scripts = {
        devenv-k8s-cluster-info.exec = ''
          kubectl cluster-info
          echo
          echo "K8s dashboard is running at https://k8s.local.lco.earth"
          echo
        '';

        devenv-k8s-cluster-up-only.exec = ''
          set -ex
          ctlptl apply -f "${./local-cluster-registry.yaml}" -f "${./local-cluster.yaml}"
        '';

        devenv-k8s-cluster-up.exec = ''
          set -ex
          devenv-k8s-cluster-up-only
          devenv-k8s-cluster-nginx-ingress-up
          devenv-k8s-cluster-dashboard-up
          devenv-k8s-cluster-update-local-lco-earth-cert

          devenv-k8s-cluster-info
        '';

        devenv-k8s-cluster-down.exec = ''
          set -ex
          ctlptl delete -f "${./local-cluster.yaml}"
        '';

        devenv-k8s-cluster-reg-down.exec = ''
          set -ex
          ctlptl delete -f "${./local-cluster-registry.yaml}"
        '';

        devenv-k8s-cluster-nginx-ingress-up.exec = ''
          set -ex -o pipefail
          kustomize build "${./ingress-nginx}" | kubectl apply --server-side -f -

          # Wait for it to to ready (more or less)
          kubectl -n ingress-nginx wait --for=condition=Complete job/ingress-nginx-admission-create job/ingress-nginx-admission-patch
          kubectl -n ingress-nginx wait --for='jsonpath={.subsets[].addresses}' ep/ingress-nginx-controller-admission

          kubectl apply --server-side --force-conflicts -f "${./configmap-coredns.yaml}"
        '';

        devenv-k8s-cluster-nginx-ingress-down.exec = ''
          set -ex -o pipefail
          kustomize build "${./ingress-nginx}" | kubectl delete -f -
          kubectl delete -f "${./configmap-coredns.yaml}"
        '';

        devenv-k8s-cluster-dashboard-up.exec = ''
          set -ex -o pipefail
          kustomize build "${./dash}" | kubectl apply --server-side -f -
        '';

        devenv-k8s-cluster-dashboard-down.exec = ''
          set -ex -o pipefail
          kustomize build "${./dash}" | kubectl delete -f -
        '';

        devenv-k8s-cluster-update-local-lco-earth-cert.exec = ''
          set -ex
          kubectl apply --server-side -f https://raw.githubusercontent.com/LCOGT/local-lco-earth-cert/refs/heads/main/tls.yaml
        '';
      };
    }

    (lib.mkIf (!cfg.setup.disable) {
      enterShell = ''
        devenv-k8s-cluster-up-only || exit 1
        devenv-k8s-cluster-info
      '';

      tasks = {
        "devenv-k8s:cluster:setupNginxIngress" = {
          exec = "devenv-k8s-cluster-nginx-ingress-up";
          before = [ "devenv:enterShell" ];
        };

        "devenv-k8s:cluster:updateLocalLcoEarthCert" = {
          exec = "devenv-k8s-cluster-update-local-lco-earth-cert";
          before = [ "devenv-k8s:cluster:setupNginxIngress" ];
        };

        "devenv-k8s:cluster:setupK8sDashboard" = {
          exec = "devenv-k8s-cluster-dashboard-up";
          before = [ "devenv-k8s:cluster:setupNginxIngress" ];
        };
      };
    })
  ]);
}
