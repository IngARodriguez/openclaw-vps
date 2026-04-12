FROM node:22-slim

# ── Herramientas base ─────────────────────────────────────────
RUN apt-get update && apt-get install -y \
    bash curl wget git vim nano \
    python3 openssh-client sudo \
    ca-certificates jq unzip htop \
    && rm -rf /var/lib/apt/lists/*

# ── GitHub CLI ────────────────────────────────────────────────
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | tee /etc/apt/sources.list.d/github-cli.list && \
    apt-get update && apt-get install -y gh && \
    rm -rf /var/lib/apt/lists/*

# ── ttyd binario directo desde GitHub ────────────────────────
RUN curl -fsSL https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64 \
    -o /usr/local/bin/ttyd && \
    chmod +x /usr/local/bin/ttyd

# ── Usuario no-root claw ──────────────────────────────────────
RUN adduser --disabled-password --gecos "" --shell /bin/bash claw && \
    echo "claw ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# ── Git config global ─────────────────────────────────────────
RUN git config --global init.defaultBranch main && \
    git config --global pull.rebase false

# ── Instalar paquetes npm globales ────────────────────────────
RUN npm install -g \
    openclaw@latest \
    @anthropic-ai/claude-code \
    @railway/cli \
    vercel \
    --force

# ── Symlinks para que claw encuentre los binarios ────────────
RUN ln -sf /usr/local/bin/openclaw /usr/bin/openclaw && \
    ln -sf /usr/local/bin/claude /usr/bin/claude && \
    ln -sf /usr/local/bin/vercel /usr/bin/vercel && \
    ln -sf /usr/local/bin/gh /usr/bin/gh

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 8080

CMD ["/start.sh"]
