# dotfiles

My personal bash dotfiles.

## Install

> TODO: write script to automate this

Before using these dotfiles, you will need to install [`stow`](https://www.gnu.org/software/stow/). It is available in most system package managers as `stow`.

For example, if you are using macOS, with [homebrew](https://brew.sh/):

```shell
brew install stow
```

With `stow` installed, you can "stow" individual packages:

```shell
stow -t ~ bash
```

You can also remove these packages:

```shell
stow -t ~ -D bash
```

## Packages

### `bash`

The `bash` package contains all the files I use to customize my bash shell.
