# devenv-k8s

A reusable [devenv](https://devenv.sh/) w/ common tools needed for Kubernetes 

## Usage

For a quick one-off shell with all the tools:

```shell
nix develop github:LCOGT/devenv-k8s/v1 --impure
```

### Import

Assuming you are using flake-parts, add the following to your `flake.nix`:

```diff
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

+   devenv-k8s.url = "github:LCOGT/devenv-k8s/v1";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
+       inputs.devenv-k8s.flakeModules.default
      ];

      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];

      perSystem = { lib, config, ... }: {

+       config.devenv.shells.default = {
+         # ...
+       };
      };
    };
}
```

Next `nix develop --impure`, it will install the packages & scripts in this devenv
in addition to any project specific ones.

### Templates

For a new project you can simply use one of the provided templates to get started:

```sh
nix flake init -t github:LCOGT/devenv-k8s#flake-parts
```

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

