#!/bin/bash

# Ruta a los archivos de configuración
DOTFILES_DIR=~/dotfiles

# Crear enlaces simbólicos
ln -sf $DOTFILES_DIR/gitconfig/.gitconfig ~/.gitconfig
ln -sf $DOTFILES_DIR/vim/.vimrc ~/.vimrc

echo "Enlaces simbólicos creados para .gitconfig y .vimrc"