#!/bin/bash
set -x
script_dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/"
rm -rf ~/.config ~/.tmux.conf ~/.zshrc
ln -s "$script_dir".config ~/.config
ln -s "$script_dir".tmux.conf ~/.tmux.conf
ln -s "$script_dir".zshrc ~/.zshrc

#NVIM Setup
git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim || true
