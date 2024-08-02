@echo off

rem Obtener el nombre de la rama actual
for /f "delims=" %%r in ('git symbolic-ref --short HEAD') do set "branch=%%r"

rem Verificar si el nombre de la rama es "main" o "master"
if "%branch%"=="main" goto :delete_branches
if "%branch%"=="master" goto :delete_branches

echo No estas en la rama "main" ni en la rama "master". El comando no se ejecutara.
exit /b

:delete_branches
rem Eliminar todas las ramas excepto "main" y "master"
for /f "delims=" %%i in ('git branch ^| findstr /v /c:"%branch%"') do git branch -D %%i

echo Todas las ramas excepto "main" o "master" se han eliminado.