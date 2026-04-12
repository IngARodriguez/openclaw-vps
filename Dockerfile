FROM node:22-slim

RUN apt-get update && apt-get install -y \
    bash curl wget git vim nano \
    python3 openssh-client \
    ca-certificates jq unzip \
    htop ttyd \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list && \
    apt-get update && apt-get install -y gh && \
    rm -rf /var/lib/apt/lists/*

RUN adduser --disabled-password --gecos "" --shell /bin/bash claw && \
    echo "claw ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN git config --global init.defaultBranch main && \
    git config --global pull.rebase false

RUN npm install -g \
    openclaw@latest \
    @anthropic-ai/claude-code \
    @railway/cli \
    vercel \
    --force

RUN ln -sf /usr/local/bin/openclaw /usr/bin/openclaw && \
    ln -sf /usr/local/bin/claude /usr/bin/claude && \
    ln -sf /usr/local/bin/vercel /usr/bin/vercel && \
    ln -sf /usr/local/bin/gh /usr/bin/gh

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 8080

CMD ["/start.sh"]
