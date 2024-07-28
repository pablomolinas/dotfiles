# Dotfiles

Este repositorio contiene mis archivos de configuración personales (dotfiles) para diversas herramientas y aplicaciones.

## Contenido

- `.gitconfig`: Configuración global de Git.
- `.vimrc`: Configuración de Vim.
- `setup_dotfiles.sh`: Script para crear enlaces simbólicos de los archivos de configuración en el directorio home.

## Instalación

Para configurar tu entorno con estos dotfiles, sigue los siguientes pasos:

1. Clona este repositorio en tu directorio home o en cualquier otro lugar que prefieras:

    ```sh
    git clone https://github.com/tu_usuario/dotfiles.git ~/dotfiles
    ```

2. Navega al directorio del repositorio:

    ```sh
    cd ~/dotfiles
    ```

3. Asegúrate de que el script `setup_dotfiles.sh` tenga permisos de ejecución:

    ```sh
    chmod +x setup_dotfiles.sh
    ```

4. Ejecuta el script para crear los enlaces simbólicos:

    ```sh
    ./setup_dotfiles.sh
    ```

Esto creará enlaces simbólicos para `.gitconfig` y `.vimrc` en tu directorio home, apuntando a los archivos en el repositorio.

## Personalización

Puedes personalizar estos archivos de configuración según tus necesidades. Simplemente edita los archivos en el repositorio y vuelve a ejecutar el script `setup_dotfiles.sh` para aplicar los cambios.

## Contribuciones

Si deseas contribuir a este repositorio, por favor abre un issue o envía un pull request con tus cambios.

## Licencia

Este proyecto está licenciado bajo la [MIT License](LICENSE).