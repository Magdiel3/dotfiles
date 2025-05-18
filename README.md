# Personal dotfiles

## Install

Clone this repo and enter to the directory where cloned

```bash
git clone git@github.com:magdiel3/dotfiles.git
cd dotfiles
```

To sync up the files into your `.config` dir, we'll use
[stow](https://www.gnu.org/software/stow/) which will create symlinks
to this repo files.

> *NOTE:* To have a correct behavior, you'll need to create the same dir structure
within your `$HOME/.config/` directory or else the symlinks created will be to the
directories here instead of the inner files.

To install the symlinks, run:

```bash
stow -t ~ tmux
```

Specify one or more targets to install the symlinks from that application.

## Planned improvements

Even though `stow` eases up the configuration, currently there's a need for some
manual steps if you don't want to get symlinks to directories but instead have only
symlinks to the files. This can be improved to having a script that creates the dirs
in `$HOME/.config/` based on the dirs in this repo.
