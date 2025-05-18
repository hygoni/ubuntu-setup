#!/bin/bash

# Install Necessary Packages

sudo apt install -y \
	ncurses-dev gawk flex bison openssl \
	libssl-dev dkms libelf-dev libudev-dev \
	libpci-dev libiberty-dev autoconf xz-utils \
	llvm clang

sudo apt install -y git
