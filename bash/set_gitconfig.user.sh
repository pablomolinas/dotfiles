#!/bin/bash

echo ""
echo "Configuración de Git:"
echo "---------------------"
read -p "Ingrese su nombre: " name
read -p "Ingrese su email: " email

GITCONFIG=~/dotfiles/gitconfig/.gitconfig.user

# Crear el archivo .gitconfig con la sección [user]
echo -e "[user]\n\tname = $name\n\temail = $email" > "$GITCONFIG"

