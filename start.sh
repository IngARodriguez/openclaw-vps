#!/bin/bash
set -e

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║     OpenClaw VPS  —  Debian Linux        ║"
echo "║     claude-code + openclaw ready        ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# PATH global para que root y claw encuentren node/npm
export PATH="/usr/local/bin:/usr/local/sbin:$PATH"

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
INSTALL_TS=$(date -u +%Y-%m-%dT%H:%M:%S.000Z)

cat > /home/claw/.openclaw/openclaw.json << EOF
{
  "agents": {
    "defaults": {
      "workspace": "/home/claw/workspace",
      "models": {
        "openrouter/meta-llama/llama-3.3-70b-instruct:free": {},
        "openrouter/nvidia/nemotron-3-super-120b-a12b:free": {},
        "github-copilot/claude-sonnet-4.6": {}
      },
      "model": {
        "primary": "github-copilot/claude-sonnet-4.6"
      },
      "compaction": {
        "mode": "safeguard"
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
      "openrouter":        { "enabled": true },
      "commit-commands":   { "enabled": true },
      "session-report":    { "enabled": true },
      "security-guidance": { "enabled": true },
      "feature-dev":       { "enabled": true },
      "github":            { "enabled": true },
      "code-review":       { "enabled": true },
      "github-copilot":    { "enabled": true }
    },
    "installs": {
      "commit-commands":   { "source": "marketplace", "installPath": "/home/claw/.openclaw/extensions/commit-commands",   "marketplaceName": "claude-plugins-official", "marketplaceSource": "claude-plugins-official", "marketplacePlugin": "commit-commands",   "installedAt": "$INSTALL_TS" },
      "session-report":    { "source": "marketplace", "installPath": "/home/claw/.openclaw/extensions/session-report",    "marketplaceName": "claude-plugins-official", "marketplaceSource": "claude-plugins-official", "marketplacePlugin": "session-report",    "installedAt": "$INSTALL_TS" },
      "security-guidance": { "source": "marketplace", "installPath": "/home/claw/.openclaw/extensions/security-guidance", "marketplaceName": "claude-plugins-official", "marketplaceSource": "claude-plugins-official", "marketplacePlugin": "security-guidance", "installedAt": "$INSTALL_TS" },
      "feature-dev":       { "source": "marketplace", "installPath": "/home/claw/.openclaw/extensions/feature-dev",       "marketplaceName": "claude-plugins-official", "marketplaceSource": "claude-plugins-official", "marketplacePlugin": "feature-dev",       "installedAt": "$INSTALL_TS" },
      "github":            { "source": "marketplace", "installPath": "/home/claw/.openclaw/extensions/github",            "marketplaceName": "claude-plugins-official", "marketplaceSource": "claude-plugins-official", "marketplacePlugin": "github",            "installedAt": "$INSTALL_TS" },
      "code-review":       { "source": "marketplace", "installPath": "/home/claw/.openclaw/extensions/code-review",       "marketplaceName": "claude-plugins-official", "marketplaceSource": "claude-plugins-official", "marketplacePlugin": "code-review",       "installedAt": "$INSTALL_TS" }
    }
  },
  "channels": {
    "telegram": {
      "enabled": true,
      "groups": { "*": { "requireMention": true } },
      "botToken": "$BOT_TOKEN"
    }
  },
  "models": {
    "providers": {
      "openrouter": {
        "baseUrl": "https://openrouter.ai/api/v1",
        "apiKey": "${OPENROUTER_API_KEY:-}",
        "api": "openai-completions",
        "models": [
          {
            "id": "meta-llama/llama-3.3-70b-instruct:free",
            "name": "Llama 3.3 70B (Free)",
            "input": ["text"],
            "contextWindow": 65536,
            "maxTokens": 8192
          },
          {
            "id": "nvidia/nemotron-3-super-120b-a12b:free",
            "name": "Nemotron 120B (Free)",
            "input": ["text"],
            "contextWindow": 262144,
            "maxTokens": 8192
          }
        ]
      }
    }
  },
  "auth": {
    "profiles": {
      "github-copilot:github": {
        "provider": "github-copilot",
        "mode": "token"
      }
    }
  },
  "skills": {
    "entries": {
      "openai-whisper-api": {
        "apiKey": "${GROQ_API_KEY:-}"
      }
    }
  }
}
EOF

# ── auth-profiles.json ────────────────────────────────────────
if [ -n "$GITHUB_COPILOT_TOKEN" ]; then
    cat > /home/claw/.openclaw/agents/main/agent/auth-profiles.json << EOF
{
  "version": 1,
  "profiles": {
    "github-copilot:github": {
      "type": "token",
      "provider": "github-copilot",
      "token": "$GITHUB_COPILOT_TOKEN"
    }
  }
}
EOF
else
    cat > /home/claw/.openclaw/agents/main/agent/auth-profiles.json << EOF
{
  "version": 1,
  "profiles": {}
}
EOF
fi

chown -R claw:claw /home/claw/.openclaw
echo "▸ OpenClaw configurado"

# ── Exportar variables de entorno al perfil de claw ──────────
cat > /home/claw/.env << ENVEOF
export PATH="/usr/local/bin:/usr/local/sbin:\$PATH:\$HOME/.local/bin"
export OPENROUTER_API_KEY="${OPENROUTER_API_KEY:-}"
export TELEGRAM_BOT_TOKEN="${TELEGRAM_BOT_TOKEN:-}"
export GITHUB_TOKEN="${GITHUB_TOKEN:-}"
export GITHUB_USER="${GITHUB_USER:-}"
export GITHUB_REPO="${GITHUB_REPO:-}"
export GIT_USER="${GIT_USER:-}"
export GIT_EMAIL="${GIT_EMAIL:-}"
export VERCEL_TOKEN="${VERCEL_TOKEN:-}"
export ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY:-}"
export GITHUB_COPILOT_TOKEN="${GITHUB_COPILOT_TOKEN:-}"
export GROQ_API_KEY="${GROQ_API_KEY:-}"
export OPENAI_BASE_URL="https://api.groq.com/openai/v1"
export OPENAI_API_KEY="${GROQ_API_KEY:-}"
ENVEOF
chown claw:claw /home/claw/.env

# ── tmux config ───────────────────────────────────────────────
cat > /home/claw/.tmux.conf << 'TMUX'
set -g mouse on
set -g history-limit 10000
set -g status-bg black
set -g status-fg green
set -g status-left '[OpenClaw VPS] '
set -g status-right '%H:%M'
set -g default-terminal "xterm-256color"
TMUX
chown claw:claw /home/claw/.tmux.conf

# ── Starship config ───────────────────────────────────────────
mkdir -p /home/claw/.config/starship
cat > /home/claw/.config/starship/starship.toml << 'STARSHIP'
# Starship — config para openclaw-vps
# Paleta: morado/cian/verde, limpio y rápido

format = """
[╭─](bold purple)\
$os\
$username\
$hostname\
$directory\
$git_branch\
$git_status\
$python\
$nodejs\
$rust\
$docker_context\
$cmd_duration\
$line_break\
[╰─](bold purple)$character"""

[os]
disabled = false
style = "bold purple"

[os.symbols]
Linux = " "
Debian = " "

[username]
show_always = false
format = "[$user]($style)[@](dimmed white)"
style_user = "bold cyan"
style_root = "bold red"

[hostname]
ssh_only = false
format = "[$hostname]($style) "
style = "bold cyan"
trim_at = "."

[directory]
format = "[$path]($style)[$read_only]($read_only_style) "
style = "bold blue"
read_only = " 󰌾"
truncation_length = 4
truncate_to_repo = true
home_symbol = "~"

[git_branch]
format = "[$symbol$branch(:$remote_branch)]($style) "
symbol = " "
style = "bold yellow"

[git_status]
format = '([$all_status$ahead_behind]($style) )'
style = "bold red"
conflicted = "⚡"
ahead = "⇡${count}"
behind = "⇣${count}"
diverged = "⇕⇡${ahead_count}⇣${behind_count}"
untracked = "?${count}"
stashed = "󰏗"
modified = "!${count}"
staged = "+${count}"
renamed = "»${count}"
deleted = "✘${count}"

[python]
format = '[${symbol}${pyenv_prefix}(${version} )(\($virtualenv\) )]($style)'
symbol = " "
style = "bold green"

[nodejs]
format = "[$symbol($version )]($style)"
symbol = " "
style = "bold green"

[rust]
format = "[$symbol($version )]($style)"
symbol = " "
style = "bold red"

[docker_context]
format = "[$symbol$context]($style) "
symbol = " "
style = "bold blue"
only_with_files = true

[cmd_duration]
min_time = 2_000
format = "[⏱ $duration]($style) "
style = "bold yellow"

[character]
success_symbol = "[❯](bold green)"
error_symbol = "[❯](bold red)"
vimcmd_symbol = "[❮](bold green)"

[line_break]
disabled = false
STARSHIP
chown -R claw:claw /home/claw/.config

# ── Monitor de recursos: res ──────────────────────────────────
mkdir -p /home/claw/.local/bin
cat > /home/claw/.local/bin/res << 'RES'
#!/bin/bash
# Monitor de recursos del sistema — uso: res

R='\033[0;31m' Y='\033[1;33m' G='\033[0;32m' C='\033[0;36m'
W='\033[1;37m' B='\033[0;34m' NC='\033[0m' BOLD='\033[1m'

bar() {
    local pct=$1 w=28
    local filled=$(( pct * w / 100 )) empty=$(( w - pct * w / 100 ))
    local color
    if   [ "$pct" -lt 60 ]; then color=$G
    elif [ "$pct" -lt 85 ]; then color=$Y
    else                          color=$R; fi
    printf "${color}["
    printf '%*s' "$filled" '' | tr ' ' '█'
    printf '%*s' "$empty"  '' | tr ' ' '░'
    printf "] %3d%%${NC}" "$pct"
}

human() {
    local b=$1
    if   [ "$b" -ge 1073741824 ]; then awk "BEGIN{printf \"%.1f GB\", $b/1073741824}"
    elif [ "$b" -ge 1048576 ];    then awk "BEGIN{printf \"%.1f MB\", $b/1048576}"
    elif [ "$b" -ge 1024 ];       then awk "BEGIN{printf \"%.1f KB\", $b/1024}"
    else echo "${b} B"; fi
}

read_cpu() { awk '/^cpu / {print $2,$3,$4,$5,$6,$7,$8,$9}' /proc/stat; }

# Detectar interfaz de red principal
NET_IF=$(ip route show default 2>/dev/null | awk '/default/{print $5}' | head -1)
[ -z "$NET_IF" ] && NET_IF="eth0"

printf '\033]2;📊 MONITOR\007'
trap 'tput cnorm; printf "\033]2;\007"; echo; exit 0' INT TERM
tput civis

while true; do
    read u1 n1 s1 i1 w1 r1 f1 st1 <<< $(read_cpu)
    t1=$(( u1+n1+s1+i1+w1+r1+f1+st1 ))
    rx1=$(cat "/sys/class/net/${NET_IF}/statistics/rx_bytes" 2>/dev/null || echo 0)
    tx1=$(cat "/sys/class/net/${NET_IF}/statistics/tx_bytes" 2>/dev/null || echo 0)
    sleep 1
    read u2 n2 s2 i2 w2 r2 f2 st2 <<< $(read_cpu)
    t2=$(( u2+n2+s2+i2+w2+r2+f2+st2 ))
    rx2=$(cat "/sys/class/net/${NET_IF}/statistics/rx_bytes" 2>/dev/null || echo 0)
    tx2=$(cat "/sys/class/net/${NET_IF}/statistics/tx_bytes" 2>/dev/null || echo 0)

    dt=$(( t2 - t1 )); di=$(( i2 + w2 - i1 - w1 ))
    cpu_pct=$(( dt > 0 ? (dt - di) * 100 / dt : 0 ))

    mem_total=$(awk '/MemTotal/    {print $2}' /proc/meminfo)
    mem_avail=$(awk '/MemAvailable/{print $2}' /proc/meminfo)
    mem_used=$(( mem_total - mem_avail ))
    mem_pct=$(( mem_total > 0 ? mem_used * 100 / mem_total : 0 ))
    mem_used_h=$(awk "BEGIN{printf \"%.1f\", $mem_used/1048576}")
    mem_total_h=$(awk "BEGIN{printf \"%.1f\", $mem_total/1048576}")

    disk_pct=$(df / | awk 'NR==2{gsub(/%/,"",$5); print $5}')
    disk_used=$(df -h / | awk 'NR==2{print $3}')
    disk_total=$(df -h / | awk 'NR==2{print $2}')

    load=$(awk '{print $1, $2, $3}' /proc/loadavg)
    procs=$(awk -F'[/ ]' '{print $4}' /proc/loadavg)
    rx_h=$(human $(( rx2 - rx1 ))); tx_h=$(human $(( tx2 - tx1 )))
    rx_total=$(human $rx2); tx_total=$(human $tx2)
    cores=$(nproc)
    uptime_h=$(awk '{s=$1; h=int(s/3600); m=int((s%3600)/60); printf "%dh %02dm", h, m}' /proc/uptime)

    clear
    echo
    echo -e "${BOLD}${C}  ╔══════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${C}  ║      MONITOR DE RECURSOS DEL SISTEMA     ║${NC}"
    echo -e "${BOLD}${C}  ╚══════════════════════════════════════════╝${NC}"
    echo
    echo -e "  ${BOLD}${W}CPU${NC}  (${cores} cores)  uptime: ${C}${uptime_h}${NC}"
    printf  "  "; bar $cpu_pct; echo
    echo -e "  Load: ${Y}$load${NC}"
    echo
    echo -e "  ${BOLD}${W}MEMORIA${NC}"
    printf  "  "; bar $mem_pct; echo
    echo -e "  ${Y}${mem_used_h}${NC} GB usados de ${C}${mem_total_h}${NC} GB"
    echo
    echo -e "  ${BOLD}${W}DISCO${NC}  (/)"
    printf  "  "; bar $disk_pct; echo
    echo -e "  ${Y}${disk_used}${NC} usados de ${C}${disk_total}${NC}"
    echo
    echo -e "  ${BOLD}${W}RED${NC}  (${NET_IF})"
    echo -e "  ${G}↓ ${rx_h}/s${NC}   ${R}↑ ${tx_h}/s${NC}"
    echo -e "  Total: recibido ${C}${rx_total}${NC}  enviado ${C}${tx_total}${NC}"
    echo
    echo -e "  ${BOLD}${W}PROCESOS ACTIVOS:${NC} ${C}${procs}${NC}"
    echo
    echo -e "  ${B}──────────────────────────────────────────${NC}"
    echo -e "  Actualizando cada segundo — ${R}Ctrl+C${NC} para salir"
done
RES
chmod +x /home/claw/.local/bin/res
chown -R claw:claw /home/claw/.local

# ── .bashrc mejorado ──────────────────────────────────────────
cat > /home/claw/.bashrc << 'BASH'
source ~/.env 2>/dev/null || true

# ── Aliases principales ───────────────────────────────────────
alias save='cd ~/workspace && git add -A && git commit -m "save: $(date +%F\ %T)" && git push && echo "✓ Guardado en GitHub"'
alias sync='cd ~/workspace && git pull && echo "✓ Sincronizado"'
alias gs='cd ~/workspace && git status'
alias workspace='cd ~/workspace'
alias claw='openclaw gateway run'
alias logs='tail -f /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log'

# ── Herramientas modernas ─────────────────────────────────────
alias ll='lsd -lah --group-dirs first'
alias ls='lsd --group-dirs first'
alias la='lsd -lah --group-dirs first'
alias lt='lsd --tree --depth 2'
alias cat='bat --style=plain --paging=never'
alias less='bat --paging=always'
alias grep='grep --color=auto'
alias diff='delta'
alias fd='fdfind'
alias find='fdfind'

# ── Historial ─────────────────────────────────────────────────
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoredups:erasedups
shopt -s histappend

export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export BAT_THEME="Dracula"

# ── Starship prompt ───────────────────────────────────────────
export STARSHIP_CONFIG=~/.config/starship/starship.toml
eval "$(starship init bash)"

# ── Monitor de recursos en panel derecho de tmux ──────────────
_res_start_monitor() {
    if [ -n "$TMUX" ]; then
        local flag
        flag=$(tmux show-environment RES_MONITOR_STARTED 2>/dev/null)
        if [ "$flag" != "RES_MONITOR_STARTED=1" ]; then
            tmux set-environment RES_MONITOR_STARTED 1
            tmux split-window -h -p 38 'res; exec bash' 2>/dev/null || true
            tmux select-pane -L 2>/dev/null || true
        fi
    fi
}
_res_start_monitor

# ── Banner de bienvenida ──────────────────────────────────────
cd ~/workspace 2>/dev/null || true

_cyan='\033[1;36m'
_purple='\033[1;35m'
_dim='\033[2m'
_reset='\033[0m'

echo ""
printf "${_purple}╭────────────────────────────────────────────╮${_reset}\n"
printf "${_purple}│${_reset}  ${_cyan}🦞 OpenClaw VPS${_reset}  ${_dim}—  Debian 12${_reset}               ${_purple}│${_reset}\n"
printf "${_purple}│${_reset}  ${_dim}save · sync · gs · claw · logs · lt · res${_reset}  ${_purple}│${_reset}\n"
printf "${_purple}╰────────────────────────────────────────────╯${_reset}\n"
echo ""
BASH

chown claw:claw /home/claw/.bashrc

# ── Arrancar OpenClaw gateway ─────────────────────────────────
echo "▸ Arrancando OpenClaw gateway..."
su - claw -c "export PATH=/usr/local/bin:/usr/local/sbin:\$HOME/.local/bin:\$PATH && \
    OPENROUTER_API_KEY='${OPENROUTER_API_KEY:-}' \
    ANTHROPIC_API_KEY='${ANTHROPIC_API_KEY:-}' \
    openclaw gateway run" &
sleep 3

echo "▸ Terminal web en :${PORT:-8080}"
TTYD_ARGS="--port ${PORT:-8080} --writable --ping-interval 30"
if [ -n "$TTYD_USER" ] && [ -n "$TTYD_PASS" ]; then
    TTYD_ARGS="$TTYD_ARGS --credential $TTYD_USER:$TTYD_PASS"
fi

exec ttyd $TTYD_ARGS su - claw -c "tmux new-session -A -s main"
