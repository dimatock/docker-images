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
# LazyVim starter ref — рекомендуется пиновать на конкретный commit SHA
# для воспроизводимости (по умолчанию main для удобства первой сборки).
ARG LAZYVIM_STARTER_REF=main

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
        jq \
        kitty-terminfo \
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

# Общие флаги curl для download шагов: таймауты + retry + force IPv4.
# Без --max-time curl зависает навсегда при stalled CDN (наблюдали 2+ мин hang
# на GitHub releases). --retry-all-errors покрывает TLS/handshake фейлы тоже.
# -4: hosts без global IPv6 связности (только ULA) ловят 10s connect timeout
# на github.com через Happy Eyeballs — force IPv4 убирает эту задержку.
ARG CURL_DL_FLAGS="-4 -fsSL --connect-timeout 10 --max-time 300 --retry 5 --retry-delay 3 --retry-all-errors"

# Neovim (pinned)
RUN OS=$(uname -s | tr '[:upper:]' '[:lower:]') && \
        ARCH=$(uname -m | sed 's/aarch64/arm64/') && \
        curl ${CURL_DL_FLAGS} -o /tmp/nvim.tar.gz \
            "https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/nvim-${OS}-${ARCH}.tar.gz" && \
        tar -xzf /tmp/nvim.tar.gz -C /usr/local --strip-components=1 && \
        rm -f /tmp/nvim.tar.gz

# lazygit (pinned)
RUN OS=$(uname -s | tr '[:upper:]' '[:lower:]') && \
        ARCH=$(uname -m | sed 's/aarch64/arm64/') && \
        curl ${CURL_DL_FLAGS} -o /tmp/lazygit.tar.gz \
            "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_${OS}_${ARCH}.tar.gz" && \
        tar -xzf /tmp/lazygit.tar.gz -C /usr/local/bin lazygit && \
        chmod +x /usr/local/bin/lazygit && \
        rm -f /tmp/lazygit.tar.gz

# Docker CLI (static binary, БЕЗ daemon — daemon должен быть на хосте,
# /var/run/docker.sock пробрасывается через devcontainer.json mounts).
RUN ARCH=$(uname -m) && \
        curl ${CURL_DL_FLAGS} -o /tmp/docker.tgz \
            "https://download.docker.com/linux/static/stable/${ARCH}/docker-${DOCKER_VERSION}.tgz" && \
        tar -xzf /tmp/docker.tgz -C /tmp && \
        install -m 0755 /tmp/docker/docker /usr/local/bin/docker && \
        rm -rf /tmp/docker /tmp/docker.tgz

# Docker Compose v2 plugin + symlink для legacy `docker-compose` вызовов
RUN ARCH=$(uname -m) && \
        mkdir -p /usr/local/lib/docker/cli-plugins && \
        curl ${CURL_DL_FLAGS} -o /usr/local/lib/docker/cli-plugins/docker-compose \
            "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-linux-${ARCH}" && \
        chmod +x /usr/local/lib/docker/cli-plugins/docker-compose && \
        ln -sf /usr/local/lib/docker/cli-plugins/docker-compose /usr/local/bin/docker-compose

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

# LazyVim: клонируем starter, удаляем .git (чтоб пользователь мог инициализировать свой repo).
RUN git clone --depth=1 --branch "${LAZYVIM_STARTER_REF}" \
            https://github.com/LazyVim/starter /home/${USER_NAME}/.config/nvim && \
        rm -rf /home/${USER_NAME}/.config/nvim/.git

# Кастомные plugin specs (oil.nvim и т.д.) — кладутся до Lazy sync, чтобы плагины
# скачались на этапе build, а не при первом запуске nvim в контейнере.
COPY --chown=${USER_NAME}:${USER_NAME} .devcontainer/nvim-plugins/ \
        /home/${USER_NAME}/.config/nvim/lua/plugins/

# Прогрев плагинов: `Lazy! sync` синхронный (bang блокирует до завершения).
# Без прогрева первый запуск nvim тратит минуты на git clone всех плагинов.
RUN nvim --headless "+Lazy! sync" +qa

# Пред-установка toolchain из .tool-versions (Go, Node.js, …)
COPY --chown=${USER_NAME}:${USER_NAME} .tool-versions /home/${USER_NAME}/.tool-versions
RUN /usr/local/bin/mise trust /home/${USER_NAME}/.tool-versions && \
        /usr/local/bin/mise install --yes

CMD ["/bin/zsh"]
