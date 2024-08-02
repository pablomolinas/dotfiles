@echo off
REM Solicitar permisos de administrador
:: Verificar si el script se está ejecutando con permisos de administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Solicitando permisos de administrador...
    powershell -Command "Start-Process cmd -ArgumentList '/c %~dpnx0' -Verb RunAs -Wait"
    exit /b
)
setlocal

REM Ruta a los archivos de configuración
set DOTFILES_DIR=%USERPROFILE%\dotfiles

REM Crear enlaces simbólicos
if exist %USERPROFILE%\.gitconfig (del %USERPROFILE%\.gitconfig)
if exist %USERPROFILE%\.vimrc (del %USERPROFILE%\.vimrc)
mklink %USERPROFILE%\.gitconfig %DOTFILES_DIR%\gitconfig\.gitconfig
mklink %USERPROFILE%\.vimrc %DOTFILES_DIR%\vim\.vimrc

echo Enlaces creados para .gitconfig y .vimrc

REM Nueva ruta a agregar
set "NEW_PATH=%DOTFILES_DIR%\bat\shared"
set "FOUND="
set "currentPath=%PATH%"

REM Verificar si NEW_PATH ya existe en el PATH
echo %PATH% | findstr /C:"%NEW_PATH%" >nul
if %errorlevel% equ 0 (
    echo La ruta ya existe en el PATH.
) else (
    echo La ruta no existe en el PATH. Agregando...
    setx PATH "%PATH%;%NEW_PATH%"
    echo Ruta agregada exitosamente.
)

REM Recargar el PATH en la instancia actual de la terminal
set "PATH=%PATH%"

REM Ejecutar script de configuración de Git
call %DOTFILES_DIR%\bat\set_gitconfig.user.bat

endlocal

echo.
echo Configuracion completada
pause
