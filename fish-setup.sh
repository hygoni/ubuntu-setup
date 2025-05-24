#!/bin/bash

sudo apt install -y fish
if [[ -n "${SUDO_USER:-}" ]]; then
    orig_user="$SUDO_USER"
else
    orig_user="$(id -un)"
fi


sudo usermod -s $(which fish) $orig_user
echo -n "New Shell For $orig_user: "
getent passwd "$orig_user" | cut -d: -f7

mkdir -p /home/$orig_user/.config/fish/config.fish
cp configs/config.fish /home/$orig_user/.config/fish/config.fish
