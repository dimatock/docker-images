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

1. **`.devcontainer/Dockerfile`** — `FROM ubuntu:26.04@sha256:…` (digest-pinned). System tools: `sudo`, `git`, `curl`, `ca-certificates`, `zsh`, `unzip`, `build-essential`, `fzf`, `ripgrep`, `fd-find`. Plus pinned downloads of `neovim`, `lazygit`, `mise`, `starship` (versions via `ARG`). Creates a `dev` user with conflict-resolution logic against the default `ubuntu` UID 1000 user on modern Ubuntu base images, and a guard against `USER_UID=0`.
2. **`.tool-versions`** at repo root — read by `mise` at **build time**. Uses canonical plugin names (`go`, `node`) and exact patch versions. The Dockerfile `COPY`s it, runs `mise trust` then `mise install --yes` — Go/Node baked into the image. Changing this file requires a rebuild.
3. **`.devcontainer/starship.toml`** — Gruvbox Rainbow prompt config, copied into `/home/dev/.config/starship.toml`.

### Pinned versions

All upstream artifacts are version-pinned in the Dockerfile via `ARG`: `NVIM_VERSION`, `LAZYGIT_VERSION`, `MISE_VERSION`, `STARSHIP_VERSION`. The base image is pinned by digest. Bump intentionally; don't switch to `stable` / `latest` tags.

### Supply-chain note

mise and starship are still installed via `curl … | sh`. Version is pinned (so the *binary* is reproducible), but the *installer script* itself is fetched fresh each build — upstream compromise would result in build-time RCE. If this matters for your threat model, replace with direct download of release tarballs from GitHub + sha256 verification.

### Build context

Builds run from the **repo root** (Makefile and `devcontainer.json` both do this). The Dockerfile `COPY`s `.devcontainer/starship.toml` and `.tool-versions` — both paths are relative to the repo root, not `.devcontainer/`. If you ever invoke `docker build` directly, set the context to `.` and the dockerfile to `.devcontainer/Dockerfile`.

### Devcontainer integration

`.devcontainer/devcontainer.json` sets `build.context: ".."` so devpod / VS Code Dev Containers build from the repo root just like the Makefile.

It does **not** pass `USER_UID`/`USER_GID` build args (devpod / Dev Containers spec has no portable way to inject host UID at build time). Image is built with `USER_UID=1000` by default. `updateRemoteUserUID: true` lets devpod / VS Code rewrite `/etc/passwd` at container start so the in-container `dev` user reflects the host UID — but this does **not** chown `/home/dev`. On Linux hosts with non-1000 UID expect permission friction for files created during the image build (e.g. `.zshrc`, baked `mise` toolchains).

Workarounds for non-1000 hosts:
- Use the Makefile (`make build` auto-detects host UID/GID) instead of devpod build.
- Or set custom build args in a personal devcontainer override.

### User creation

The Dockerfile's user-creation block:
- Refuses `USER_UID=0` (would delete root).
- Deletes any pre-existing user/group at `USER_UID`/`USER_GID` before creating the `dev` user — required because Ubuntu 24.04+ ships a default `ubuntu` user at UID 1000.
- Grants `NOPASSWD:ALL` sudo to `dev` via `/etc/sudoers.d/dev`. Convenient for dev work, **do not use this image in shared / production environments**.

### Workspace paths

Three paths must stay aligned:
- `Makefile` `WORKSPACE := /workspaces/$(notdir $(CURDIR))`
- `devcontainer.json` `workspaceFolder: "/workspaces/${localWorkspaceFolderBasename}"`
- (Dockerfile `WORKDIR` is `/home/dev` — that's the home dir, separate concern.)

`make run` and devpod both mount the host repo at `/workspaces/<repo-name>` so behavior matches.

## Conventions

- Comments in Dockerfile, Makefile, and `.tool-versions` are in Russian — match the existing language when editing.
- Don't reintroduce an Alpine variant: prebuilt `neovim` / `lazygit` binaries are glibc-linked and break on musl without `gcompat`.
- Don't use floating tags (`latest`, `stable`, `22`). Always pin exact versions.
