# Dash/Zeal docsets for `nix`, `nixpkgs`, `nix-os`, `nix-darwin` and `home-manager`

This repository packages:

- The [nix reference manual][0] into a `nix.docset`.
- The [Nixpkgs reference manual][1] into a `nixpkgs.docset`.
- The [NixOS Manual][2] into a `nixos.docset`.
- The [nix-darwin Manual][3] into a `nix-darwin.docset`.
- The [Home Manager Manual][4] into a `home-manager.docset`.

## The docsets

You can find the docsets:

1. In the [releases section][5] (sporadically updated).
1. In [GitHub pages][10] (updated weekly, from a nightly job).
1. As artifacts from CI builds (updated weekly, from a nightly job).

## `dasht` one-liner

If you use [`dasht`][6], you can launch it and search against all docsets as
follows:

```bash
DASHT_DOCSETS_DIR=$(nix build github:aldur/nixpkgs.docset --print-out-paths) nix run nixpkgs#dasht fetchfromgithub
```

If you don't want to build the docs, you can get the [latest `.tgz`][11] that
includes them all:

```bash
DASHT_DOCSETS_DIR=${mktmp -d}
export DASHT_DOCSETS_DIR
curl https://aldur.github.io/nixpkgs.docset/all.tgz | tar -xzf - -C $DASHT_DOCSETS_DIR
nix run nixpkgs#dasht fetchfromgithub
```

You can also get the manuals for a specific `nixpkgs` version by overriding the
`nixpkgs` input in `nix build`:

```bash
DASHT_DOCSETS_DIR=$(nix build --override-input nixpkgs nixpkgs github:aldur/nixpkgs.docset --print-out-paths) nix run nixpkgs#dasht fetchfromgithub
```

## Build

```bash
nix build
```

You'll find the produced `.docset`s under the `result` directory:

```bash
» ls -l result/
total 0
dr-xr-xr-x  4 root  wheel  128 Jan  1  1970 home-manager.docset
dr-xr-xr-x  4 root  wheel  128 Jan  1  1970 nix-darwin.docset
dr-xr-xr-x  4 root  wheel  128 Jan  1  1970 nix.docset
dr-xr-xr-x  4 root  wheel  128 Jan  1  1970 nixos.docset
dr-xr-xr-x  4 root  wheel  128 Jan  1  1970 nixpkgs.docset
```

The build against `nixpkgs-unstable` will generally be fast (because most
packages will be in the online cache), but unfortunately `nix-manual` requires
`nix-cli` and will most likely build from source, taking some time to do that.

## Similar projects

- [devdocs.io/nix/][7], web-based, covers built-ins only.
- [nix-dash-docsets][8], very similar to this project (but I discovered it too
  late!). It provides XML feeds for Dash.
- [nix-docgen/][9], publishes a Dash/Zeal feed for `nixpkgs`.

[0]: https://nix.dev/manual/nix/latest/
[1]: https://nixos.org/manual/nixpkgs/unstable/
[2]: https://nixos.org/manual/nixpkgs/unstable/
[3]: https://daiderd.com/nix-darwin/manual/index.html
[4]: https://nix-community.github.io/home-manager/index.xhtml
[5]: https://github.com/aldur/nixpkgs.docset/releases
[6]: https://github.com/sunaku/dasht
[7]: https://devdocs.io/nix/
[8]: https://github.com/boinkor-net/nix-dash-docsets.md
[9]: https://nixosbrasil.github.io/nix-docgen/
[10]: https://aldur.github.io/nixpkgs.docset
[11]: https://aldur.github.io/nixpkgs.docset/all.tgz
