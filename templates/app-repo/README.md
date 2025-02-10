# app-name

One line blurb about what this application does.

More information about this app.

## Development

### Shell

Always enter the development shell before doing anything else. This will make
sure everyone is using the same version of tools, to avoid any system discrepancies.

Install [Nix](https://github.com/LCOGT/public-wiki/wiki/Install-Nix) if you have
not already.

If you have [direnv](https://github.com/LCOGT/public-wiki/wiki/Install-direnv)
installed, the shell will automatically activate and deactive anytime you change
directories. You may have to grant permissions initially with:

```sh
direnv allow
```

Otherwise, you can manually enter the shell with:

```sh
./develop.sh
```

### Skaffold

Deploy application dependencies:

```sh
skaffold -m <app>-deps run
```

Start application development loop:

```sh
skaffold -m <app> dev
```

If there are any Ingresses, they should be exposed at:
  - http://<app>.local.lco.earth
