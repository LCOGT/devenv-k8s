# devenv-k8s

A reusable [devenv](https://devenv.sh/) w/ common tools needed for Kubernetes 

## Usage

For a quick one-off shell with all the tools:

```shell
nix develop github:LCOGT/devenv-k8s --impure
```

### Import

Assuming you're using flake-parts, add the following to your `flake.nix`:

```diff
diff --git a/flake.nix b/flake.nix
index 23e54fd..070e011 100644
--- a/flake.nix
+++ b/flake.nix
@@ -5,10 +5,12 @@
     nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
     devenv.url = "github:cachix/devenv";
     nix2container.url = "github:nlewo/nix2container";
     nix2container.inputs.nixpkgs.follows = "nixpkgs";
     mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";
+
+    devenv-k8s.url = "github:LCOGT/devenv-k8s";
   };
 
   nixConfig = {
     extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
     extra-substituters = "https://devenv.cachix.org";
@@ -24,11 +26,11 @@
       perSystem = { config, self', inputs', pkgs, system, ... }: {
 
         devenv.shells.default = {
           # https://devenv.sh/reference/options/
           packages = [
-
+            inputs'.devenv-k8s.devShells.default
           ];
 
         };
 
       };
```
Next `nix develop --impure`, it will install the packages & scripts in this devenv
in addition to any project specific ones.

### Updates

To pull in changes from upstream you need to run the following in the project that imports this:

```shell
nix flake update devenv-k8s
```

## Cache

Some tools may require compiling. You can setup Nix to pull from a pre-built
binary cache. This only needs to be done once:

```shell
nix profile install nixpkgs#cachix
cachix use lco-public
```

