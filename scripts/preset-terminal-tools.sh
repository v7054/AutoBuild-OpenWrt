#!/usr/bin/env bash

mkdir -p files/root

git clone -q --depth=1 https://github.com/ohmyzsh/ohmyzsh.git files/root/.oh-my-zsh
git clone -q --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git files/root/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone -q --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git files/root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

[[ -f "${GITHUB_WORKSPACE}/scripts/.zshrc" ]] && cp -f "${GITHUB_WORKSPACE}/scripts/.zshrc" files/root/.zshrc

printf '[ \e[32mSUCCESS\e[0m ] %s\n' "[${0##*/}] done"
exit 0