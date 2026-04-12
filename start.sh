#!/bin/bash
set -e

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║     OpenClaw VPS  —  Alpine Linux        ║"
echo "║     github-cli + vercel + claude-code    ║"
echo "╚══════════════════════════════════════════╝"
echo ""

if [ -n "$GIT_USER" ] && [ -n "$GIT_EMAIL" ]; then
    git config --global user.name  "$GIT_USER"
    git config --global user.email "$GIT_EMAIL"
    su - claw -c "git config --global user.name '$GIT_USER'"
    su - claw -c "git config --global user.email '$GIT_EMAIL'"
fi

if [ -n "$GITHUB_TOKEN" ] && [ -n "$GITHUB_USER" ]; then
    git config --global credential.helper store
    echo "https://$GITHUB_USER:$GITHUB_TOKEN@github.com" > /root/.git-credentials
    echo "https://$GITHUB_USER:$GITHUB_TOKEN@github.com" > /home/claw/.git-credentials
    chmod 600 /root/.git-credentials /home/claw/.git-credentials
    chown claw:claw /home/claw/.git-credentials
    su - claw -c "git config --global credential.helper store"
    echo "▸ GitHub configurado"
fi

WORKSPACE="/home/claw/workspace"
mkdir -p "$WORKSPACE"
chown claw:claw "$WORKSPACE"

if [ -n "$GITHUB_TOKEN" ] && [ -n "$GITHUB_USER" ] && [ -n "$GITHUB_REPO" ]; then
    REPO_URL="https://$GITHUB_USER:$GITHUB_TOKEN@github.com/$GITHUB_USER/$GITHUB_REPO.git"
    if [ -d "$WORKSPACE/.git" ]; then
        su - claw -c "cd $WORKSPACE && git pull --quiet"
    else
        su - claw -c "git clone --quiet '$REPO_URL' '$WORKSPACE'" 2>/dev/null || {
            su - claw -c "cd $WORKSPACE && git init --quiet && \
                git remote add origin '$REPO_URL' && \
                echo '# OpenClaw Workspace' > README.md && \
                git add . && git commit -m 'init' --quiet && \
                git push -u origin main --quiet" 2>/dev/null || true
        }
    fi
    echo "▸ Workspace sincronizado"
fi

if [ -n "$GITHUB_TOKEN" ]; then
    su - claw -c "echo '$GITHUB_TOKEN' | gh auth login --with-token" 2>/dev/null || true
    echo "▸ GitHub CLI autenticado"
fi

if [ -n "$VERCEL_TOKEN" ]; then
    mkdir -p /home/claw/.local/share/vercel
    echo "{\"token\":\"$VERCEL_TOKEN\"}" > /home/claw/.local/share/vercel/auth.json
    chown -R claw:claw /home/claw/.local
    echo "▸ Vercel autenticado"
fi

mkdir -p /home/claw/.openclaw/agents/main/agent
chown -R claw:claw /home/claw/.openclaw

GATEWAY_TOKEN=$(cat /home/claw/.openclaw/.gateway_token 2>/dev/null || \
    tr -dc 'a-f0-9' < /dev/urandom | head -c 48)
echo "$GATEWAY_TOKEN" > /home/claw/.openclaw/.gateway_token

BOT_TOKEN="${TELEGRAM_BOT_TOKEN:-}"

cat > /home/claw/.openclaw/openclaw.json << EOF
{
  "agents": {
    "defaults": {
      "workspace": "/home/claw/.openclaw/workspace",
      "models": {
        "openrouter/google/gemini-2.0-flash-001": {}
      },
      "model": {
        "primary": "openrouter/google/gemini-2.0-flash-001"
      }
    }
  },
  "gateway": {
    "mode": "local",
    "auth": {
      "mode": "token",
      "token": "$GATEWAY_TOKEN"
    },
    "port": 18789,
    "bind": "loopback",
    "tailscale": { "mode": "off", "resetOnExit": false },
    "controlUi": { "allowInsecureAuth": true }
  },
  "session": { "dmScope": "per-channel-peer" },
  "tools": { "profile": "coding" },
  "plugins": {
    "entries": {
      "openrouter": { "enabled": true }
    }
  },
  "channels": {
    "telegram": {
      "enabled": true,
      "groups": { "*": { "requireMention": true } },
      "botToken": "$BOT_TOKEN"
    }
  }
}
EOF

cat > /home/claw/.openclaw/agents/main/agent/auth-profiles.json << EOF
{
  "openrouter": {
    "default": {
      "apiKey": "${OPENROUTER_API_KEY:-}"
    }
  }
}
EOF

chown -R claw:claw /home/claw/.openclaw
echo "▸ OpenClaw configurado"

# ── Exportar variables de entorno al perfil de claw ───────────
cat > /home/claw/.env << ENVEOF
export OPENROUTER_API_KEY="${OPENROUTER_API_KEY:-}"
export TELEGRAM_BOT_TOKEN="${TELEGRAM_BOT_TOKEN:-}"
export GITHUB_TOKEN="${GITHUB_TOKEN:-}"
export GITHUB_USER="${GITHUB_USER:-}"
export GITHUB_REPO="${GITHUB_REPO:-}"
export GIT_USER="${GIT_USER:-}"
export GIT_EMAIL="${GIT_EMAIL:-}"
export VERCEL_TOKEN="${VERCEL_TOKEN:-}"
export ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY:-}"
ENVEOF
chown claw:claw /home/claw/.env

cat > /home/claw/.bashrc << 'BASH'
source ~/.env 2>/dev/null || true
export PATH="$PATH:/home/claw/.npm-global/bin"
alias save='cd ~/workspace && git add -A && git commit -m "save: $(date +%F\ %T)" && git push && echo "✓ Guardado en GitHub"'
alias sync='cd ~/workspace && git pull && echo "✓ Sincronizado"'
alias gs='cd ~/workspace && git status'
alias ll='ls -lah'
alias workspace='cd ~/workspace'
alias claw='OPENROUTER_API_KEY=$OPENROUTER_API_KEY openclaw gateway run'
alias logs='tail -f /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log'
cd ~/workspace 2>/dev/null || true
clear
echo ""
echo "╔══════════════════════════════════════════╗"
echo "║     OpenClaw VPS  —  Alpine Linux        ║"
echo "║  save | sync | gs | claw | logs          ║"
echo "╚══════════════════════════════════════════╝"
echo ""
BASH

chown claw:claw /home/claw/.bashrc

echo "▸ Arrancando OpenClaw gateway..."
su - claw -c "OPENROUTER_API_KEY='${OPENROUTER_API_KEY:-}' ANTHROPIC_API_KEY='${ANTHROPIC_API_KEY:-}' openclaw gateway run" &
sleep 3

echo "▸ Terminal web en :${PORT:-8080}"
TTYD_ARGS="--port ${PORT:-8080} --writable"
if [ -n "$TTYD_USER" ] && [ -n "$TTYD_PASS" ]; then
    TTYD_ARGS="$TTYD_ARGS --credential $TTYD_USER:$TTYD_PASS"
fi

exec ttyd $TTYD_ARGS su - claw
