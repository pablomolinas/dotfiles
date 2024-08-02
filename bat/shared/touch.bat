@echo off
REM Verificar que se han pasado dos parámetros
if "%~1"=="" (
    echo Debes especificar un nombre de archivo.
    goto end
)

echo. > %1

:end