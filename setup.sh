#!/bin/bash
set -e

echo "Check and install zplug"
if ! [[ -d "${HOME}/.zplug" ]]; then
    curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh| zsh
else
    echo "zplug already installed"
fi

echo "Check and install Miniconda..."
if ! hash conda 2>/dev/null; then
    if [[ $OSTYPE == *darwin* ]]; then
        wget https://repo.continuum.io/miniconda/Miniconda3-latest-MacOSX-x86_64.sh -O ${HOME}/miniconda.sh
    fi

    if [[ $OSTYPE == *linux* ]]; then
        wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ${HOME}/miniconda.sh
    fi
    bash ${HOME}/miniconda.sh -b -p ${HOME}/Applications/miniconda
    rm ${HOME}/miniconda.sh
    [[ ":$PATH:" != *":$HOME/Applications/miniconda/bin:"* ]] && export PATH=$HOME/Applications/miniconda/bin:$PATH
fi

echo "Setup python environment for neovim..."
if ! (conda env list | grep "^neovim3" &>/dev/null) then
    conda create --name neovim3 python=3.6
fi

source activate neovim3

if ! (conda list | grep "^neovim" &>/dev/null) then
    conda install -c conda-forge neovim
fi

if ! (conda list | grep "^flake8" &>/dev/null) then
    conda install -c anaconda flake8
    [[ -d "${HOME}/.local/bin" ]] || mkdir -p ${HOME}/.local/bin
    ln -fs `which flake8` ${HOME}/.local/bin/flake8
fi
[[ ":$PATH:" != *":$HOME/.local/bin:"* ]] && export PATH=$HOME/.local/bin:$PATH

source deactivate neovim3

if ! (conda env list | grep "^neovim2" &>/dev/null) then
    conda create --name neovim2 python=2.7
fi

source activate neovim2

if ! (conda list | grep "^neovim" &>/dev/null) then
    conda install -c conda-forge neovim
fi

source deactivate neovim2

echo "Check and Install vim-plug"
if ! [[ -f "${HOME}/.local/share/nvim/site/autoload/plug.vim" ]]; then
    curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
else
    echo "vim-plug already installed"
fi

if ! hash nvim 2>/dev/null; then
    echo "Install Neovim at https://github.com/neovim/neovim/wiki/Installing-Neovim"
fi
