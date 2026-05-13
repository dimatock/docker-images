# Makefile для сборки Docker-образа dev-среды

IMAGE ?= dev-env
DOCKERFILE := .devcontainer/Dockerfile

# Локальные UID/GID для bind-mount без permission проблем
USER_UID ?= $(shell id -u)
USER_GID ?= $(shell id -g)

.PHONY: all build run clean help

all: build

# Собрать образ
build:
	@echo "==> Сборка $(IMAGE) (UID=$(USER_UID) GID=$(USER_GID))..."
	docker build \
		--build-arg USER_UID=$(USER_UID) \
		--build-arg USER_GID=$(USER_GID) \
		-t $(IMAGE) \
		-f $(DOCKERFILE) .
	@echo "==> Готово: $(IMAGE)"

# Запустить интерактивный shell в образе
run:
	docker run --rm -it -v $(CURDIR):/workspace -w /workspace $(IMAGE)

# Удалить образ
clean:
	-docker rmi $(IMAGE)

help:
	@echo "Сборка Docker-образа dev-среды"
	@echo ""
	@echo "Команды:"
	@echo "  make build   Собрать образ (по умолчанию: $(IMAGE))"
	@echo "  make run     Запустить интерактивный shell в образе"
	@echo "  make clean   Удалить образ"
	@echo "  make help    Показать справку"
	@echo ""
	@echo "Переменные:"
	@echo "  IMAGE=name:tag   Тэг образа (default: dev-env)"
	@echo "  USER_UID=N       UID dev-пользователя (default: текущий)"
	@echo "  USER_GID=N       GID dev-пользователя (default: текущий)"

.DEFAULT_GOAL := help
