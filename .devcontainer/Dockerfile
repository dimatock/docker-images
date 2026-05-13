# Dev environment image: Ubuntu 26.04 LTS + mise-managed toolchain
FROM ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

ARG USER_NAME=dev
ARG USER_UID=1000
ARG USER_GID=1000
ARG LAZYGIT_VERSION=0.61.0

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
RUN if getent passwd ${USER_UID} >/dev/null; then \
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

# Neovim (stable, glibc-prebuilt)
RUN OS=$(uname -s | tr '[:upper:]' '[:lower:]') && \
        ARCH=$(uname -m | sed 's/aarch64/arm64/') && \
        curl -fsSL -o /tmp/nvim.tar.gz \
            "https://github.com/neovim/neovim/releases/download/stable/nvim-${OS}-${ARCH}.tar.gz" && \
        tar -xzf /tmp/nvim.tar.gz -C /usr/local --strip-components=1 && \
        rm -f /tmp/nvim.tar.gz

# lazygit
RUN OS=$(uname -s | tr '[:upper:]' '[:lower:]') && \
        ARCH=$(uname -m | sed 's/aarch64/arm64/') && \
        curl -fsSL -o /tmp/lazygit.tar.gz \
            "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_${OS}_${ARCH}.tar.gz" && \
        tar -xzf /tmp/lazygit.tar.gz -C /usr/local/bin lazygit && \
        chmod +x /usr/local/bin/lazygit && \
        rm -f /tmp/lazygit.tar.gz

# mise + starship (system-wide)
RUN curl -fsSL https://mise.run | MISE_INSTALL_PATH=/usr/local/bin/mise sh && \
        curl -fsSL https://starship.rs/install.sh | sh -s -- --yes

USER ${USER_NAME}
WORKDIR /home/${USER_NAME}

# Shell config
COPY --chown=${USER_NAME}:${USER_NAME} .devcontainer/starship.toml /home/${USER_NAME}/.config/starship.toml

RUN printf '\n# mise + starship\neval "$(/usr/local/bin/mise activate zsh)"\neval "$(starship init zsh)"\n' \
        >> /home/${USER_NAME}/.zshrc

# Пред-установка toolchain из .tool-versions (Go, Node.js, …)
COPY --chown=${USER_NAME}:${USER_NAME} .tool-versions /home/${USER_NAME}/.tool-versions
RUN /usr/local/bin/mise install --yes

CMD ["/bin/zsh"]
