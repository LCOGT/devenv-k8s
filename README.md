# devenv-k8s

A reusable [devenv](https://devenv.sh/) w/ common tools needed for Kubernetes 

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
+    flake: true
+imports:
+  - k8s
```

Or if using a flake-parts, add this repo to inputs and follow
https://devenv.sh/guides/using-with-flake-parts/#import-a-devenv-module

Next time you do `devenv shell` or `nix develop --impure`, it will install all
packages listed in [devenv.nix](devenv.nix) in addition to any project specific ones.

## Cache

Some tools may require compiling. Run the following to setup the LCO Cachix Nix cache that will
let you pull pre-built binaries. This only needs to be done once.

```shell
cachix use lco-public
```

## Updates

To pull in changes from upstream you need to run the following in the project that imports this:

```shell
devenv update
```

Or you can declaritively lock it to a specific ref. See https://devenv.sh/reference/yaml-options/.

For flakes,

```shell
nix flake update devenv-k8s
```
