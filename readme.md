# Dotfiles

Este repositorio contiene mis archivos de configuración personales (dotfiles) para diversas herramientas y aplicaciones.

## Contenido

- `.gitconfig`: Configuración global de Git, agrega algunos alias utiles.
- `.vimrc`: Configuración de Vim.
- `setup_dotfiles.sh`: Script para crear enlaces simbólicos de los archivos de configuración en el directorio home en Linux.
- `setup_dotfiles.bat`: Script para configurar los dotfiles en Windows y agregar una carpeta al PATH en Windows.

Al ejecutar el script en tu SO corresepondiente solicita Nombre e Email para agregarlos a la configuracion de git local.

## Instalación

### En Linux

Para configurar tu entorno con estos dotfiles en Linux, sigue los siguientes pasos:

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

### En Windows

Para configurar tu entorno con estos dotfiles en Windows, sigue los siguientes pasos:

1. Clona este repositorio en tu directorio home o en cualquier otro lugar que prefieras:

    ```sh
    git clone https://github.com/tu_usuario/dotfiles.git %USERPROFILE%\dotfiles
    ```

2. Navega al directorio del repositorio:

    ```sh
    cd %USERPROFILE%\dotfiles
    ```

3. Asegúrate de que el script `setup_dotfiles.bat` tenga permisos de ejecución:

    ```bat
    icacls setup_dotfiles.bat /grant %USERNAME%:F
    ```

4. Ejecuta el script para configurar los dotfiles y agregar una carpeta al PATH:

    ```bat
    setup_dotfiles.bat
    ```

El script `setup_dotfiles.bat` suscribe una carpeta al PATH de Windows para que los algunos alias de comandos linux estén disponibles de forma global. Solicita permisos de administrador.