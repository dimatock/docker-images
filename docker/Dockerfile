# Использование стабильного базового образа
FROM ubuntu:26.04

# Использование стабильного базового образа
FROM ubuntu:26.04

# Установка переменных окружения для non-interactive установки
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8

# Add arguments for user, group IDs, and username
ARG USER_NAME=dev
ARG USER_UID=1000
ARG USER_GID=1000

# Установка основных зависимостей и утилит
RUN apt-get update && apt-get install -y \
    sudo \
    git \
    curl \
    zsh \
    unzip \
    build-essential \
    fzf \
    ripgrep \
    fd-find \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Создание non-root пользователя с доступом к sudo
RUN groupadd -g $USER_GID $USER_NAME && useradd -u $USER_UID -g $USER_GID -m -s /bin/zsh -d /home/$USER_NAME $USER_NAME && usermod -aG sudo $USER_NAME
RUN echo "$USER_NAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER $USER_NAME
WORKDIR /home/$USER_NAME


# Установка Neovim
RUN OS=$(uname -s | tr '[:upper:]' '[:lower:]') && \
    ARCH=$(uname -m | sed 's/aarch64/arm64/') && \
    curl -Lo nvim.tar.gz https://github.com/neovim/neovim/releases/download/stable/nvim-$OS-$ARCH.tar.gz \
  && sudo tar -xzf nvim.tar.gz -C /usr/local --strip-components=1 \
  && rm -f nvim.tar.gz

# Установка lazygit
RUN LG_VERSION="0.61.0" && \
    OS=$(uname -s | tr '[:upper:]' '[:lower:]') && \
    ARCH=$(uname -m | sed 's/aarch64/arm64/') && \
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v$LG_VERSION/lazygit_${LG_VERSION}_${OS}_${ARCH}.tar.gz" \
  && tar xf lazygit.tar.gz lazygit \
  && sudo install lazygit /usr/local/bin \
  && rm -rf lazygit lazygit.tar.gz

# Установка mise (ex-rtx) и starship
USER root
RUN curl https://mise.run | MISE_INSTALL_PATH=/usr/local/bin/mise sh
RUN curl -sS https://starship.rs/install.sh | sh -s -- --yes
USER $USER_NAME

# Настройка shell
RUN mkdir -p /home/$USER_NAME/.config
COPY docker/starship.toml /home/$USER_NAME/.config/starship.toml

RUN echo '\n# Mise and Starship configuration' >> /home/$USER_NAME/.zshrc && \
    echo 'eval "$(/usr/local/bin/mise activate zsh)"' >> /home/$USER_NAME/.zshrc && \
    echo 'eval "$(starship init zsh)"' >> /home/$USER_NAME/.zshrc

# Указываем, что будем использовать zsh по умолчанию
CMD ["/bin/zsh"]

CMD ["/bin/zsh"]
