# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

Devcontainer-style Docker image for a Go + Node.js dev environment, used with `devpod` and other Dev Containers–compatible tools. Single image variant: Ubuntu 26.04 LTS.

## Common commands

```bash
make build                                    # build dev-env image
make run                                      # interactive shell in image
make clean                                    # remove image
make help                                     # default target — prints help
make build IMAGE=my-env:tag USER_UID=1001     # override image tag / user IDs
```

`.DEFAULT_GOAL := help` — bare `make` prints help, use `make build` to actually build.

No test or lint targets. After modifying the Dockerfile, validate with `make build`.

## Architecture

Three coupled pieces that must be edited together:

1. **`.devcontainer/Dockerfile`** — `FROM ubuntu:26.04`. Installs toolchain (`neovim`, `lazygit`, `mise`, `starship`, `fzf`, `ripgrep`, `fd-find`). Creates a `dev` user with conflict-resolution logic against the default `ubuntu` UID 1000 user on modern Ubuntu base images.
2. **`.tool-versions`** at repo root — read by `mise` at **build time**. The Dockerfile `COPY`s it into the image and runs `mise install --yes`, so Go/Node.js are baked in. Changing this file requires a rebuild.
3. **`.devcontainer/starship.toml`** — Gruvbox Rainbow prompt config, copied into `/home/dev/.config/starship.toml`.

### Build context

Builds run from the **repo root** (Makefile already does this). The Dockerfile `COPY`s `.devcontainer/starship.toml` and `.tool-versions` — both paths are relative to the repo root, not `.devcontainer/`. If you ever invoke `docker build` directly, set the context to `.` and the dockerfile to `.devcontainer/Dockerfile`.

### Devcontainer integration

`.devcontainer/devcontainer.json` sets `build.context: ".."` so devpod / VS Code Dev Containers build from the repo root just like the Makefile. Build args (`USER_NAME`, `USER_UID`, `USER_GID`) are passed through — keep them in sync with the Dockerfile's `ARG` declarations.

### User creation

The Dockerfile's user-creation block deletes any pre-existing user/group at `USER_UID`/`USER_GID` before creating the `dev` user. This is required because Ubuntu 24.04+ ships a default `ubuntu` user at UID 1000. Don't simplify this without testing on a fresh `ubuntu:26.04` base.

## Conventions

- Comments in Dockerfile and Makefile are in Russian — match the existing language when editing.
- `lazygit` version is pinned via `ARG LAZYGIT_VERSION` in the Dockerfile. Bump intentionally; don't switch to "latest".
- Don't reintroduce an Alpine variant: prebuilt `neovim` / `lazygit` binaries are glibc-linked and break on musl without `gcompat`.
