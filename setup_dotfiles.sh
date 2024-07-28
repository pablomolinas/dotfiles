#!/bin/bash

# Ruta a los archivos de configuración
DOTFILES_DIR=~/dotfiles

# Crear enlaces simbólicos
ln -sf $DOTFILES_DIR/gitconfig/.gitconfig ~/.gitconfig
ln -sf $DOTFILES_DIR/vim/.vimrc ~/.vimrc

echo "Enlaces simbólicos creados para .gitconfig y .vimrc"

# Añadir entrada a .bashrc si no existe
BASHRC=~/.bashrc
CUSTOM_BASHRC_ENTRY="if [ -f ~/dotfiles/custom_bashrc ]; then
    . ~/dotfiles/bashconfig/.bashconfig
fi"

# Verificar si la entrada ya existe en .bashrc
if ! grep -q "dotfiles/custom_bashrc" "$BASHRC"; then
    echo "$CUSTOM_BASHRC_ENTRY" >> "$BASHRC"
    echo "Entrada para incluir .bashconfig añadida a .bashrc"
else
    echo "La entrada para incluir .bashconfig ya existe en .bashrc"
fi