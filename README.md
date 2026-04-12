# Docker-based Development Environment

This repository contains the configuration for a Docker-based development environment optimized for Go and Frontend (Node.js) development. It is designed to be used with `devpod`.

## Features

- **Base Image**: `Ubuntu 22.04` for stability and compatibility.
- **Language Runtimes**: Managed via `mise` (`.tool-versions` file). Includes `golang` and `nodejs` by default.
- **Editor**: Pre-installed latest stable version of `Neovim`.
- **Shell**: `zsh` with `starship` prompt, configured with the "Gruvbox Rainbow" theme.
- **Core Tools**: `git`, `curl`, `sudo`, `build-essential`, `fzf`, `ripgrep`, `fd-find`.
- **Git TUI**: `lazygit` is included for a convenient terminal-based git workflow.

## File Structure

- `docker/Dockerfile`: The main file for building the Docker image.
- `docker/starship.toml`: The configuration file for the `starship` prompt theme.
- `devcontainer.json`: Configuration for `devpod` and other dev container compatible tools. It tells them how to build and manage the environment.
- `.tool-versions`: A `mise` configuration file to specify the versions of Go, Node.js, and any other tools you need.

## Usage

### 1. Build the Docker Image

You can build the image manually using the following command. The `-t` flag tags the image with a name for easier reference.

```bash
docker build -t dev-environment -f docker/Dockerfile .
```

Alternatively, `devpod` will build the image automatically using the instructions from `devcontainer.json` if it doesn't find a pre-built image.

### 2. Running with Devpod

Simply point `devpod` to this repository. It will read the `devcontainer.json` file and set up the environment accordingly.

### 3. Inside the Container: First Steps

Once the container is running and you are in the shell, you need to install the tool versions specified in the `.tool-versions` file.

```bash
mise install
```
This command will read the `.tool-versions` file and download and install the specified versions of Go and Node.js. Thanks to the shell hooks we set up, `mise` will automatically use these versions in your project directory.

## Customization

- **Change Tool Versions**: To change the version of Go or Node.js, simply edit the `.tool-versions` file and run `mise install` again inside the container.
- **Add Tools**: You can add more tools managed by `mise` (like `python`, `ruby`, etc.) to the `.tool-versions` file.
- **Modify the Environment**: To add more system-level packages or change the setup, edit the `docker/Dockerfile` and rebuild the image.
