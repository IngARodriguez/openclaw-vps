FROM alpine:3.19

RUN apk add --no-cache \
    bash curl wget git vim nano \
    nodejs npm python3 \
    openssh-client ca-certificates \
    jq unzip htop ttyd

RUN sed -i 's|/bin/ash|/bin/bash|' /etc/passwd 2>/dev/null || true

RUN git config --global init.defaultBranch main && \
    git config --global pull.rebase false

WORKDIR /root

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 8080

CMD ["/start.sh"]
