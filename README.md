# my-blog

## Running using Nix

To start the live server using Nix:

```sh
just run
```

To build the static website via Nix:

```sh
nix build -o ./result
# Then test it:
nix run nixpkgs#nodePackages.live-server -- ./result
```
