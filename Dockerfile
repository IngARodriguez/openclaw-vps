FROM node:22-alpine

RUN apk add --no-cache \
    bash curl wget git vim nano \
    python3 openssh-client \
    ca-certificates jq unzip \
    htop ttyd github-cli

RUN adduser -D -s /bin/bash -h /home/claw claw && \
    echo "claw ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN git config --global init.defaultBranch main && \
    git config --global pull.rebase false

USER claw
RUN npm install -g \
    openclaw@latest \
    @anthropic-ai/claude-code \
    @railway/cli \
    vercel \
    --force

USER root

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 8080

CMD ["/start.sh"]
