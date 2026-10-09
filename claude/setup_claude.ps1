# Configura Claude Code a nivel usuario a partir de los dotfiles:
#  - Enlaza settings.json, statusline, agents y skills en %USERPROFILE%\.claude
#  - Instala los plugins listados en plugins.txt
# Requiere permisos de administrador (o Modo desarrollador) para crear enlaces simbolicos.

$ErrorActionPreference = 'Stop'

$SourceDir = $PSScriptRoot
$ClaudeDir = Join-Path $env:USERPROFILE '.claude'
$BackupDir = Join-Path $ClaudeDir ("backups\dotfiles-" + (Get-Date -Format 'yyyyMMdd-HHmmss'))

function Set-Link([string]$Source, [string]$Target) {
    $existing = Get-Item -LiteralPath $Target -Force -ErrorAction SilentlyContinue
    if ($existing) {
        if ($existing.LinkType) {
            if (@($existing.Target) -contains $Source) {
                Write-Host "  ok      $Target"
                return
            }
            # Borra solo el enlace, sin seguirlo hacia el destino
            if ($existing.PSIsContainer) { [System.IO.Directory]::Delete($Target) }
            else { [System.IO.File]::Delete($Target) }
        }
        else {
            New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null
            Move-Item -LiteralPath $Target -Destination $BackupDir
            Write-Host "  backup  $Target -> $BackupDir"
        }
    }
    New-Item -ItemType SymbolicLink -Path $Target -Target $Source | Out-Null
    Write-Host "  link    $Target"
}

$probe = Join-Path $env:TEMP ("claude-link-probe-" + [guid]::NewGuid())
try {
    New-Item -ItemType SymbolicLink -Path $probe -Target $PSCommandPath | Out-Null
    Remove-Item -LiteralPath $probe -Force
}
catch {
    Write-Error "No se pueden crear enlaces simbolicos. Ejecuta como administrador (setup_dotfiles.bat lo hace) o activa el Modo desarrollador de Windows."
    exit 1
}

Write-Host "Enlazando configuracion de Claude Code en $ClaudeDir"
New-Item -ItemType Directory -Force -Path (Join-Path $ClaudeDir 'agents'), (Join-Path $ClaudeDir 'skills') | Out-Null

Set-Link (Join-Path $SourceDir 'settings.json') (Join-Path $ClaudeDir 'settings.json')
Set-Link (Join-Path $SourceDir 'statusline-command.sh') (Join-Path $ClaudeDir 'statusline-command.sh')

if (Test-Path (Join-Path $SourceDir 'CLAUDE.md')) {
    Set-Link (Join-Path $SourceDir 'CLAUDE.md') (Join-Path $ClaudeDir 'CLAUDE.md')
}

# Se enlaza cada agente y skill por separado para que lo que Claude Code genere
# dentro de esas carpetas (skills/synced, skills/.trash, etc.) no termine en el repo.
Get-ChildItem -Path (Join-Path $SourceDir 'agents') -File | ForEach-Object {
    Set-Link $_.FullName (Join-Path $ClaudeDir "agents\$($_.Name)")
}
Get-ChildItem -Path (Join-Path $SourceDir 'skills') -Directory | ForEach-Object {
    Set-Link $_.FullName (Join-Path $ClaudeDir "skills\$($_.Name)")
}

Write-Host ""
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    Write-Warning "No se encontro el comando 'claude'. Instala Claude Code y volve a ejecutar este script para instalar los plugins."
    exit 0
}

Write-Host "Instalando plugins de Claude Code"
$ErrorActionPreference = 'Continue'
Get-Content (Join-Path $SourceDir 'plugins.txt') | ForEach-Object {
    $line = $_.Trim()
    if (-not $line -or $line.StartsWith('#')) { return }
    if ($line -match '^marketplace\s+(.+)$') {
        claude plugin marketplace add $Matches[1]
    }
    else {
        claude plugin install $line
    }
}

Write-Host ""
Write-Host "Claude Code configurado"
