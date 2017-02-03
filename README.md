# souman

Small utility to download and build packages from source using the [Arch Build System (ABS)](https://wiki.archlinux.org/index.php/Arch_Build_System). The build and install process is handled by [makepkg](https://wiki.archlinux.org/index.php/makepkg).


## Install
Use your favorite AUR helper and install `souman`.

Make sure to sync the ABS tree before you install a package, this can be done with `souman -y`.

## Usage
```
/usr/bin/souman [options] [package(s)]

Options:
 -h, --help     Display this help message then exit.
 -V, --version  Display version information then exit.
 -y, --refresh  Sync repositories using ABS.

If no argument is given, souman will search in $HOME/.cache/souman for synced repositories.
The sync is completely managed by abs, so you may want to edit /etc/abs.conf.
```

### Examples

Download latest ABS snapshot, build and install gzip:
```
$ souman -y gzip
==> Downloading tarballs...
    ==> core...
    ==> extra...
    ==> community...
    ==> multilib...
==> Building core/gzip...
==> Making package: gzip 1.8-2 (Fri Feb  3 19:33:04 CET 2017)
==> Checking runtime dependencies...
==> Checking buildtime dependencies...
==> Retrieving sources...
  -> Downloading gzip-1.8.tar.xz...
...
```
