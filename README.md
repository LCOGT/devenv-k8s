# devenv-k8s

A reusable devenv w/ common tools needed for Kubernetes 

## Usage

To import this devenv into another, add the following to your `devenv.yaml`:

```diff
diff --git a/devenv.yaml b/devenv.yaml
index c7cb5ce..75410d4 100644
--- a/devenv.yaml
+++ b/devenv.yaml
@@ -1,3 +1,8 @@
 inputs:
   nixpkgs:
     url: github:NixOS/nixpkgs/nixpkgs-unstable
+  k8s:
+    url: git+https://github.com/LCOGT/devenv-k8s
+    flake: false
+imports:
+  - k8s
```

Next time you do `devenv shell`, it will install all packages listed in [devenv](devenv.nix)
in addition to any project specific ones.

## Updates

To pull in changes from upstream you need to run in the project that imports this:

```shell
devenv update
```

Or you can declaritively lock it to a specific ref. See https://devenv.sh/inputs/.
