@echo off
echo.

set GITCONFIG=%USERPROFILE%\dotfiles\gitconfig\.gitconfig.aliasesSO.bat

rem Crear el archivo .gitconfig con la sección [alias]
(
    echo [alias]
    echo     cobf  = "!f() { git checkout -b feature/$1; }; f"
    echo     cobft = "!f() { git checkout -b feature/task$1; }; f"
    echo     cobh  = "!f() { git checkout -b hotfix/$1; }; f"
) > "%GITCONFIG%"