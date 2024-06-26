# Dot-files and dot-files installer

## About

This project contains the dot-files and misc utilities that I use on the
command line.

## Install

```bash
cd $HOME
git clone git@github.com:hattwj/dot_files.git
cd dot_files
./install
```

### Extras

#### dvim - Dockerized vim

`./scripts/vimd` is a shell script that is included in the $PATH that will
run a dockerized version of vim.

`./extras/vimd-exec` is a shell wrapper that allows executing commands inside
of the vimd container. It manages permissions as well.

`./extras/Dockerfile` is the dockerfile that manages how the container is built

`./extras/vimd-build` is a shell script to build a named image for use with the
other scripts.

#### ackrep - Recursive search and replace

`./scripts/ackrep` is a script to recursively search and replace strings in the
text files of a project.

## Uninstall

```bash
cd $HOME
cd dot_files
./uninstall
```
