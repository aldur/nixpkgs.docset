# Dash/Zeal docset for `nixpkgs`

Packages the [Nixpkgs reference manual](https://nixos.org/manual/nixpkgs/unstable/) into a `nixpkgs.docset`.

## Build

```bash
nix build
```

You'll find the `.docset` in `result`:

```bash
INSERT 17:40:37 aldur@Maui ~/W/nixpkgs_docset
    » tree result/nixpkgs.docset/
result/nixpkgs.docset/
├── Contents
│   ├── Info.plist
│   └── Resources
│       ├── Documents
│       │   ├── _redirects
│       │   ├── anchor-use.js
│       │   ├── anchor.min.js
│       │   ├── highlightjs
│       │   │   ├── LICENSE
│       │   │   ├── highlight.pack.js
│       │   │   ├── loader.js
│       │   │   └── mono-blue.css
│       │   ├── index-redirects.js
│       │   ├── index.html
│       │   ├── release-notes-redirects.js
│       │   ├── release-notes.html
│       │   └── style.css
│       └── docSet.dsidx
└── icon.png

5 directories, 15 files
```
