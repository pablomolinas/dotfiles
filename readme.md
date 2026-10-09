# Dotfiles

Este repositorio contiene mis archivos de configuración personales (dotfiles) para diversas herramientas y aplicaciones.

## Contenido

- `.gitconfig`: Configuración global de Git, agrega algunos alias utiles.
- `.vimrc`: Configuración de Vim.
- `claude/`: Configuración de Claude Code a nivel usuario (settings, statusline, subagentes, skills y plugins). Ver la sección [Claude Code](#claude-code).
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

## Claude Code

La carpeta `claude/` replica la forma de trabajo con Claude Code en cualquier PC. `setup_dotfiles.bat` / `setup_dotfiles.sh` ejecutan automáticamente `claude/setup_claude.ps1` / `claude/setup_claude.sh`, que también se pueden correr por separado.

| Archivo / carpeta | Destino | Descripción |
|---|---|---|
| `settings.json` | `~/.claude/settings.json` | Modelo, statusline, plugins habilitados y preferencias generales |
| `statusline-command.sh` | `~/.claude/statusline-command.sh` | Statusline: modelo, carpeta, % de contexto y estado de git (requiere `node`) |
| `agents/*.md` | `~/.claude/agents/` | Subagentes personalizados |
| `skills/*/` | `~/.claude/skills/` | Skills personalizadas |
| `plugins.txt` | — | Marketplaces y plugins que se instalan con `claude plugin install` |
| `CLAUDE.md` (opcional) | `~/.claude/CLAUDE.md` | Instrucciones globales; se enlaza solo si existe |

El script crea **enlaces simbólicos**, así que cualquier cambio hecho desde Claude Code (por ejemplo editar una skill) queda directamente en el repo. Si en el destino ya existe un archivo o carpeta real, se mueve a `~/.claude/backups/dotfiles-<fecha>/` antes de enlazarlo.

Los agentes y las skills se enlazan uno por uno, por lo que una skill nueva creada en `~/.claude/skills/` no se versiona sola: hay que moverla a `claude/skills/` y volver a correr el script.

Las skills `tdd` y `find-skills` son copias de [mattpocock/skills](https://github.com/mattpocock/skills) y [vercel-labs/skills](https://github.com/vercel-labs/skills).

**No se versiona** (es estado o datos propios de cada PC): `.credentials.json`, `history.jsonl`, `projects/` (incluye la memoria), `sessions/`, `plugins/cache`, `settings.local.json` y `~/.claude.json`.

**Requisitos:** tener Claude Code instalado antes de correr el script; si no, se crean los enlaces pero se omite la instalación de plugins. Al terminar, ejecutar `claude` para iniciar sesión y autenticar los MCP de los plugins que lo pidan (Postman, Context7, etc.) con `/mcp`.

Para agregar un servidor MCP a nivel usuario: `claude mcp add --scope user <nombre> -- <comando>`.
