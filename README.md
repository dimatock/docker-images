# Docker-based Development Environment

Devcontainer-style Docker-образ для Go + Node.js разработки. Используется с [devpod](https://devpod.sh/), VS Code Dev Containers, JetBrains Dev Containers и совместимыми инструментами.

## Состав

- **Base**: `Ubuntu 26.04 LTS`
- **Toolchain**: управляется через [`mise`](https://mise.jdx.dev/) (см. `.tool-versions`) — Go, Node.js
- **Editor**: последний стабильный `Neovim`
- **Shell**: `zsh` + `starship` (тема Gruvbox Rainbow)
- **Утилиты**: `git`, `curl`, `sudo`, `build-essential`, `fzf`, `ripgrep`, `fd-find`
- **Git TUI**: `lazygit`

## Структура

```
.
├── .devcontainer/
│   ├── devcontainer.json   # Конфиг для devpod / VS Code Dev Containers
│   ├── Dockerfile          # Образ
│   └── starship.toml       # Тема prompt
├── .tool-versions          # Версии toolchain (читает mise)
├── .dockerignore
└── Makefile
```

## Использование

### С devpod / Dev Containers

Указать devpod на этот репозиторий — он прочитает `.devcontainer/devcontainer.json` и поднимет окружение автоматически.

### Ручная сборка

```bash
make build              # собрать образ dev-env
make run                # запустить интерактивный shell
make clean              # удалить образ
make help               # справка
```

Кастомные параметры:

```bash
make build IMAGE=my-env:1.0 USER_UID=1001 USER_GID=1001
```

Toolchain из `.tool-versions` запекается в образ при сборке (Go, Node.js доступны сразу — без `mise install` после старта).

## Кастомизация

- **Версии toolchain**: правка `.tool-versions` → `make build`
- **Доп. инструменты mise**: добавить в `.tool-versions` (python, ruby, …)
- **Системные пакеты**: правка `.devcontainer/Dockerfile`
- **Prompt**: правка `.devcontainer/starship.toml`
