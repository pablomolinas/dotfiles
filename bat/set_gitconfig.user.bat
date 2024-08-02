@echo off
echo.
echo Configuracion de Git:
echo ---------------------
set /p name=Ingrese su nombre: 
set /p email=Ingrese su email: 

set GITCONFIG=%USERPROFILE%\dotfiles\gitconfig\.gitconfig.user

rem Crear el archivo .gitconfig con la sección [user]
(
    echo [user]
    echo     name = %name%
    echo     email = %email%
) > "%GITCONFIG%"