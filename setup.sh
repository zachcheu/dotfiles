#!/bin/bash
script_dir=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
cd $script_dir
ln -s .config ~/.config
ln -s .tmux.conf ~/.tmux.conf
ln -s .zshrc ~/.zshrc
