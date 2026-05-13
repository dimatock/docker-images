# Dev environment image: Ubuntu 26.04 LTS + mise-managed toolchain
# Базовый образ закреплён по digest для воспроизводимости.
FROM ubuntu:26.04@sha256:f3d28607ddd78734bb7f71f117f3c6706c666b8b76cbff7c9ff6e5718d46ff64

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

ARG USER_NAME=dev
ARG USER_UID=1000
ARG USER_GID=1000

# Pinned tool versions
ARG NVIM_VERSION=0.12.2
ARG LAZYGIT_VERSION=0.61.0
ARG MISE_VERSION=v2026.5.6
ARG STARSHIP_VERSION=v1.25.1
ARG DOCKER_VERSION=29.4.2
ARG COMPOSE_VERSION=v5.1.3

# Базовые зависимости
RUN apt-get update && apt-get install -y --no-install-recommends \
        sudo \
        git \
        curl \
        ca-certificates \
        zsh \
        unzip \
        build-essential \
        fzf \
        ripgrep \
        fd-find \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Создание dev-пользователя.
# Ubuntu 24.04+ содержит дефолтного 'ubuntu' с UID 1000 — резолвим конфликт.
# Защита от USER_UID=0 (не сносим root).
RUN if [ "${USER_UID}" = "0" ]; then \
            echo "USER_UID=0 not allowed (would delete root)" >&2; exit 1; \
        fi && \
        if getent passwd ${USER_UID} >/dev/null; then \
            existing_user=$(getent passwd ${USER_UID} | cut -d: -f1); \
            userdel -r "$existing_user" 2>/dev/null || true; \
        fi && \
        if getent group ${USER_GID} >/dev/null && \
             [ "$(getent group ${USER_GID} | cut -d: -f1)" != "${USER_NAME}" ]; then \
            existing_group=$(getent group ${USER_GID} | cut -d: -f1); \
            groupdel "$existing_group"; \
        fi && \
        if ! getent group ${USER_GID} >/dev/null; then \
            groupadd -g ${USER_GID} ${USER_NAME}; \
        fi && \
        useradd -u ${USER_UID} -g ${USER_GID} -m -s /bin/zsh -d /home/${USER_NAME} ${USER_NAME} && \
        usermod -aG sudo ${USER_NAME} && \
        echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USER_NAME} && \
        chmod 0440 /etc/sudoers.d/${USER_NAME}

# Neovim (pinned)
RUN OS=$(uname -s | tr '[:upper:]' '[:lower:]') && \
        ARCH=$(uname -m | sed 's/aarch64/arm64/') && \
        curl -fsSL -o /tmp/nvim.tar.gz \
            "https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/nvim-${OS}-${ARCH}.tar.gz" && \
        tar -xzf /tmp/nvim.tar.gz -C /usr/local --strip-components=1 && \
        rm -f /tmp/nvim.tar.gz

# lazygit (pinned)
RUN OS=$(uname -s | tr '[:upper:]' '[:lower:]') && \
        ARCH=$(uname -m | sed 's/aarch64/arm64/') && \
        curl -fsSL -o /tmp/lazygit.tar.gz \
            "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_${OS}_${ARCH}.tar.gz" && \
        tar -xzf /tmp/lazygit.tar.gz -C /usr/local/bin lazygit && \
        chmod +x /usr/local/bin/lazygit && \
        rm -f /tmp/lazygit.tar.gz

# Docker CLI (static binary, БЕЗ daemon — daemon должен быть на хосте,
# /var/run/docker.sock пробрасывается через devcontainer.json mounts).
RUN ARCH=$(uname -m) && \
        curl -fsSL -o /tmp/docker.tgz \
            "https://download.docker.com/linux/static/stable/${ARCH}/docker-${DOCKER_VERSION}.tgz" && \
        tar -xzf /tmp/docker.tgz -C /tmp && \
        install -m 0755 /tmp/docker/docker /usr/local/bin/docker && \
        rm -rf /tmp/docker /tmp/docker.tgz

# Docker Compose v2 plugin
RUN ARCH=$(uname -m) && \
        mkdir -p /usr/local/lib/docker/cli-plugins && \
        curl -fsSL -o /usr/local/lib/docker/cli-plugins/docker-compose \
            "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-linux-${ARCH}" && \
        chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# mise (pinned). Установщик скачивается с mise.run — версия фиксирована через MISE_VERSION.
# Замечание: установщик исполняется через `sh`. Если боитесь supply-chain compromise — замените
# на прямой download tarball с https://github.com/jdx/mise/releases и sha256 verify.
RUN curl -fsSL https://mise.run | MISE_VERSION=${MISE_VERSION} MISE_INSTALL_PATH=/usr/local/bin/mise sh

# starship (pinned). Установщик starship.rs/install.sh поддерживает флаг -v.
RUN curl -fsSL https://starship.rs/install.sh | sh -s -- --yes -v ${STARSHIP_VERSION}

USER ${USER_NAME}
WORKDIR /home/${USER_NAME}

# Shell config
COPY --chown=${USER_NAME}:${USER_NAME} .devcontainer/starship.toml /home/${USER_NAME}/.config/starship.toml

RUN printf '\n# mise + starship\neval "$(/usr/local/bin/mise activate zsh)"\neval "$(starship init zsh)"\n' \
        >> /home/${USER_NAME}/.zshrc

# Пред-установка toolchain из .tool-versions (Go, Node.js, …)
COPY --chown=${USER_NAME}:${USER_NAME} .tool-versions /home/${USER_NAME}/.tool-versions
RUN /usr/local/bin/mise trust /home/${USER_NAME}/.tool-versions && \
        /usr/local/bin/mise install --yes

CMD ["/bin/zsh"]
