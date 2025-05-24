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

# Copy config
mkdir -p /home/$orig_user/.config/fish/config.fish
cp configs/config.fish /home/$orig_user/.config/fish/config.fish

# Install plugins
wget https://raw.githubusercontent.com/jichu4n/fish-command-timer/refs/heads/master/conf.d/fish_command_timer.fish -O ~/.config/fish/conf.d/fish_command_timer.fish
