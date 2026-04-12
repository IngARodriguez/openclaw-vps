FROM node:22-alpine

RUN apk add --no-cache \
    bash curl wget git vim nano \
    python3 openssh-client \
    ca-certificates jq unzip htop ttyd

RUN git config --global init.defaultBranch main && \
    git config --global pull.rebase false

WORKDIR /root

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 8080

CMD ["/start.sh"]
