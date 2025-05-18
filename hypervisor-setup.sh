#!/bin/bash

if [[ -n "${SUDO_USER:-}" ]]; then
    orig_user="$SUDO_USER"
else
    orig_user="$(id -un)"
fi

sudo apt install -y \
	qemu-kvm libvirt-daemon-system libvirt-clients \
	bridge-utils virtinst guestfs-tools libguestfs-tools \
	virt-manager

sudo systemctl enable libvirtd
sudo systemctl start libvirtd

sudo usermod -aG libvirt,kvm $orig_user
sudo -u $orig_user newgrp libvirt
