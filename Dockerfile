FROM node:22-alpine

RUN apk add --no-cache \
    bash curl wget git vim nano \
    python3 openssh-client \
    ca-certificates jq unzip \
    htop ttyd github-cli sudo

RUN adduser -D -s /bin/bash -h /home/claw claw && \
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
