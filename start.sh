#!/bin/bash
set -e

echo ""
echo "╔══════════════════════════════════════╗"
echo "║     OpenClaw VPS  —  Alpine Linux    ║"
echo "╚══════════════════════════════════════╝"
echo ""

# ── Git identity ──────────────────────────────────────────────
if [ -n "$GIT_USER" ] && [ -n "$GIT_EMAIL" ]; then
    git config --global user.name  "$GIT_USER"
    git config --global user.email "$GIT_EMAIL"
    echo "▸ Git: $GIT_USER <$GIT_EMAIL>"
fi

# ── GitHub token ──────────────────────────────────────────────
if [ -n "$GITHUB_TOKEN" ] && [ -n "$GITHUB_USER" ]; then
    git config --global credential.helper store
    echo "https://$GITHUB_USER:$GITHUB_TOKEN@github.com" > /root/.git-credentials
    chmod 600 /root/.git-credentials
    echo "▸ GitHub token OK"
fi

# ── Clonar repo como disco local ──────────────────────────────
WORKSPACE="/root/workspace"
mkdir -p "$WORKSPACE"

if [ -n "$GITHUB_TOKEN" ] && [ -n "$GITHUB_USER" ] && [ -n "$GITHUB_REPO" ]; then
    REPO_URL="https://$GITHUB_USER:$GITHUB_TOKEN@github.com/$GITHUB_USER/$GITHUB_REPO.git"

    if [ -d "$WORKSPACE/.git" ]; then
        echo "▸ Sincronizando workspace desde GitHub..."
        cd "$WORKSPACE" && git pull --quiet
    else
        echo "▸ Clonando $GITHUB_USER/$GITHUB_REPO como disco..."
        git clone --quiet "$REPO_URL" "$WORKSPACE" 2>/dev/null || {
            echo "▸ Repo vacío — inicializando..."
            cd "$WORKSPACE"
            git init --quiet
            git remote add origin "$REPO_URL"
            echo "# OpenClaw Workspace" > README.md
            git add . 
            git commit -m "init: workspace" --quiet
            git push -u origin main --quiet 2>/dev/null || true
        }
    fi
    echo "▸ Disco listo → $WORKSPACE"
else
    echo "▸ Sin GitHub configurado — disco temporal (se borra al reiniciar)"
fi

# ── Aliases útiles ────────────────────────────────────────────
cat >> /root/.bashrc << 'BASH'

# ── OpenClaw VPS helpers ──
alias save='cd /root/workspace && git add -A && git commit -m "save: $(date +%F\ %T)" && git push && echo "✓ Guardado en GitHub"'
alias sync='cd /root/workspace && git pull && echo "✓ Sincronizado"'
alias gs='cd /root/workspace && git status'
alias ll='ls -lah'
alias workspace='cd /root/workspace'

# Ir al workspace al abrir terminal
cd /root/workspace 2>/dev/null || true
clear
echo ""
echo "╔══════════════════════════════════════╗"
echo "║     OpenClaw VPS  —  Alpine Linux    ║"
echo "║  Disco: /root/workspace → GitHub     ║"
echo "║  Comandos: save | sync | gs          ║"
echo "╚══════════════════════════════════════╝"
echo ""
BASH

echo ""
echo "▸ Terminal web iniciando en :${PORT:-8080}"
echo ""

# ── Lanzar ttyd ───────────────────────────────────────────────
TTYD_ARGS="--port ${PORT:-8080} --writable"

# Contraseña si está definida
if [ -n "$TTYD_USER" ] && [ -n "$TTYD_PASS" ]; then
    TTYD_ARGS="$TTYD_ARGS --credential $TTYD_USER:$TTYD_PASS"
    echo "▸ Acceso protegido: usuario=$TTYD_USER"
else
    echo "▸ Acceso abierto (define TTYD_USER y TTYD_PASS para proteger)"
fi

exec ttyd $TTYD_ARGS bash
