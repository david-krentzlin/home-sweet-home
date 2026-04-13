#!/bin/bash
set -eux -o pipefail

dnf install -y git curl sudo ca-certificates chezmoi zsh zsh-autosuggestions openssh-clients podman tmux ripgrep fd-find bat eza zoxide fzf jq tar unzip gzip make gcc gcc-c++ helm

usermod -s /bin/zsh dev

install -d -m 755 -o dev -g dev /home/dev/code

if ! command -v mise >/dev/null 2>&1; then
	if dnf copr enable -y jdxcode/mise; then
		dnf install -y mise
	else
		curl https://mise.run | MISE_INSTALL_PATH=/usr/local/bin/mise sh
	fi
fi
