#!/bin/bash

# Pathogen
mkdir -p ~/.vim/autoload ~/.vim/bundle && \
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

pushd ~/.vim/bundle
git clone https://github.com/tpope/vim-fugitive
git clone https://github.com/tpope/vim-surround
git clone https://github.com/mattn/gist-vim.git
git clone https://github.com/maksimr/vim-jsbeautify
git clone https://github.com/scrooloose/syntastic
git clone https://github.com/kien/ctrlp.vim
git clone https://github.com/marijnh/tern_for_vim
git clone https://github.com/bitc/vim-bad-whitespace
git clone https://github.com/bling/vim-airline
git clone https://github.com/ap/vim-css-color
git clone https://github.com/flazz/vim-colorschemes
git clone https://github.com/Valloric/YouCompleteMe
git clone https://github.com/marijnh/tern_for_vim
popd

