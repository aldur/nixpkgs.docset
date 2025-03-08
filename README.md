# Dash/Zeal docsets for `nix`, `nixpkgs` and `nix-os`

This repository packages:

- The [nix reference manual](https://nix.dev/manual/nix/latest/) into a `nix.docset`.
- The [Nixpkgs reference manual](https://nixos.org/manual/nixpkgs/unstable/) into a `nixpkgs.docset`.
- The [NixOS Manual](https://nixos.org/manual/nixpkgs/unstable/) into a `nixos.docset`.

## The docsets

You can find the docsets:

1. In the [releases section](https://github.com/aldur/nixpkgs.docset/releases).
1. As artifacts from CI builds (weekly, from nightly).

## Build

```bash
nix build
```

You'll find the produced `.docset`s under the `result` directory:

```bash
    » ls -la result/
total 0
dr-xr-xr-x      5 root  wheel       160 Jan  1  1970 .
drwxrwxr-t@ 65535 root  nixbld  5016608 Mar  8 13:02 ..
dr-xr-xr-x      4 root  wheel       128 Jan  1  1970 nix.docset
dr-xr-xr-x      4 root  wheel       128 Jan  1  1970 nixos.docset
dr-xr-xr-x      4 root  wheel       128 Jan  1  1970 nixpkgs.docset
```
