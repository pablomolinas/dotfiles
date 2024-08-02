@echo off
REM Verificar que se han pasado dos parámetros
if "%~1"=="" (
    echo Debes especificar un alias.
    goto end
)

if "%~2"=="" (
    echo Debes especificar un comando.
    goto end
)

REM Agregar el alias a Git
git config --global alias.%1 "%~2"

echo Alias '%1' agregado con el comando '%~2'.

:end