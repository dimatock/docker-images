# Makefile для сборки Docker-образов среды разработки

# ==============================================================================
# Переменные
# ?= позволяет переопределять переменные из командной строки
# Пример: make build-alpine IMAGE_ALPINE=my-custom-env:latest
# ==============================================================================
IMAGE_UBUNTU ?= dev-env-ubuntu
IMAGE_ALPINE ?= dev-env-alpine

# ==============================================================================
# Основные цели
# ==============================================================================

# Цель по умолчанию: собирает основной образ (Ubuntu)
.PHONY: all
all: build

# Собрать основной образ (Ubuntu)
.PHONY: build
build: build-ubuntu

# Собрать образ на базе Ubuntu
.PHONY: build-ubuntu
build-ubuntu:
	@echo "==> Сборка образа на базе Ubuntu: $(IMAGE_UBUNTU)..."
	docker build -t $(IMAGE_UBUNTU) -f docker/Dockerfile .
	@echo "==> Сборка $(IMAGE_UBUNTU) завершена."

# Собрать образ на базе Alpine
.PHONY: build-alpine
build-alpine:
	@echo "==> Сборка образа на базе Alpine: $(IMAGE_ALPINE)..."
	docker build -t $(IMAGE_ALPINE) -f docker/Dockerfile.alpine .
	@echo "==> Сборка $(IMAGE_ALPINE) завершена."


# ==============================================================================
# Служебные цели
# ==============================================================================

# Показать справку
.PHONY: help
help:
	@echo "Инструменты для сборки Docker-образов"
	@echo ""
	@echo "Доступные команды:"
	@echo "  make build         (или make) Собрать образ по умолчанию (Ubuntu)."
	@echo "  make build-ubuntu  Собрать образ на базе Ubuntu."
	@echo "  make build-alpine  Собрать образ на базе Alpine."
	@echo "  make help          Показать это справочное сообщение."
	@echo ""
	@echo "Вы можете переопределить имена образов:"
	@echo "  make build-alpine IMAGE_ALPINE=my-alpine:1.0"

.DEFAULT_GOAL := help
