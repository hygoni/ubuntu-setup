#!/bin/bash

if [[ -n "${SUDO_USER:-}" ]]; then
    orig_user="$SUDO_USER"
else
    orig_user="$(id -un)"
fi

# Install Necessary Packages

sudo apt install -y \
	ncurses-dev gawk flex bison openssl \
	libssl-dev dkms libelf-dev libudev-dev \
	libpci-dev libiberty-dev autoconf xz-utils \
	llvm clang

sudo apt install -y git vim

# Git setup

sudo -u $orig_user git config --global core.editor vim
sudo -u $orig_user git config --global user.name "Harry Yoo"
sudo -u $orig_user git config --global user.email "harry.yoo@oracle.com"
