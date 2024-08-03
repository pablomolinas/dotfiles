#!/bin/bash

# Ruta a los archivos de configuración
DOTFILES_DIR=~/dotfiles

# Crear enlaces simbólicos
ln -sf $DOTFILES_DIR/gitconfig/.gitconfig ~/.gitconfig
ln -sf $DOTFILES_DIR/vim/.vimrc ~/.vimrc

echo "Enlaces simbólicos creados para .gitconfig y .vimrc"

# Añadir entrada a .bashrc si no existe
BASHRC=~/.bashrc
BASHCONFIG_PATH=$DOTFILES_DIR/bash/config/.bashconfig

# Verificar si la entrada ya existe en .bashrc
if ! grep -q $BASHCONFIG_PATH $BASHRC; then
    echo "" >> "$BASHRC"
    echo "" >> "$BASHRC"
    echo 'if [ -f '"$BASHCONFIG_PATH"' ]; then' >> $BASHRC
    echo '    . '"$BASHCONFIG_PATH" >> $BASHRC
    echo 'fi' >> $BASHRC
    echo "Entrada para incluir .bashconfig añadida a .bashrc"
else
    echo "La entrada para incluir .bashconfig ya existe en .bashrc"
fi

$DOTFILES_DIR/bash/set_gitconfig.user.sh

# Reload .bashrc
source "$BASHRC"
echo ".bashrc reloaded"
echo ""
echo "Configuración completada"