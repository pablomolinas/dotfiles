#!/bin/bash
# Configura Claude Code a nivel usuario a partir de los dotfiles:
#  - Enlaza settings.json, statusline, agents y skills en ~/.claude
#  - Instala los plugins listados en plugins.txt

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR=~/.claude
BACKUP_DIR="$CLAUDE_DIR/backups/dotfiles-$(date +%Y%m%d-%H%M%S)"

link() {
    local source=$1 target=$2
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        mkdir -p "$BACKUP_DIR"
        mv "$target" "$BACKUP_DIR/"
        echo "  backup  $target -> $BACKUP_DIR"
    fi
    ln -sfn "$source" "$target"
    echo "  link    $target"
}

echo "Enlazando configuracion de Claude Code en $CLAUDE_DIR"
mkdir -p "$CLAUDE_DIR/agents" "$CLAUDE_DIR/skills"

link "$SOURCE_DIR/settings.json" "$CLAUDE_DIR/settings.json"
link "$SOURCE_DIR/statusline-command.sh" "$CLAUDE_DIR/statusline-command.sh"
[ -f "$SOURCE_DIR/CLAUDE.md" ] && link "$SOURCE_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"

# Se enlaza cada agente y skill por separado para que lo que Claude Code genere
# dentro de esas carpetas (skills/synced, skills/.trash, etc.) no termine en el repo.
for f in "$SOURCE_DIR"/agents/*.md; do
    link "$f" "$CLAUDE_DIR/agents/$(basename "$f")"
done
for d in "$SOURCE_DIR"/skills/*/; do
    d=${d%/}
    link "$d" "$CLAUDE_DIR/skills/$(basename "$d")"
done

echo ""
if ! command -v claude >/dev/null 2>&1; then
    echo "No se encontro el comando 'claude'. Instala Claude Code y volve a ejecutar este script para instalar los plugins."
    exit 0
fi

echo "Instalando plugins de Claude Code"
while IFS= read -r line || [ -n "$line" ]; do
    line=$(echo "$line" | tr -d '\r' | xargs)
    case "$line" in
        ''|'#'*) continue ;;
        marketplace\ *) claude plugin marketplace add "${line#marketplace }" ;;
        *) claude plugin install "$line" ;;
    esac
done < "$SOURCE_DIR/plugins.txt"

echo ""
echo "Claude Code configurado"
