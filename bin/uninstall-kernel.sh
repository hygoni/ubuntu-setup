#!/usr/bin/env bash
#
# pick-and-purge-kernels.sh
#
#   • Presents the list of kernels found in /lib/modules with check-boxes
#   • Lets you toggle selection (space) and confirm (Enter)
#   • Removes /lib/modules/<ver> plus matching /boot/{vmlinuz,initrd,config,System.map}-<ver>
#   • Rebuilds your GRUB menu if grub.cfg is on the box
#
# Dependencies : bash, coreutils, fzf (>=0.35 for --multi --bind)
# Usage        : sudo ./pick-and-purge-kernels.sh
# -------------------------------------------------------------------------

set -euo pipefail

need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing $1 – install it first."; exit 1; }; }

need ls
need uname

if ! command -v fzf >/dev/null; then
    echo "⚠️  fzf not found."
    echo "    On Fedora/RHEL/OL      : sudo dnf install fzf"
    echo "    On Debian/Ubuntu       : sudo apt install fzf"
    echo "    On Arch                : sudo pacman -S fzf"
    echo "    Or grab a static binary: https://github.com/junegunn/fzf#installation"
    exit 1
fi

running="$(uname -r)"
mapfile -t kernels < <(ls -1 /lib/modules | sort -V)

if [ "${#kernels[@]}" -le 1 ]; then
    echo "Only one kernel present – nothing to delete."
    exit 0
fi

# Build the fzf input: prepend a star to the running kernel so users see it is untouchable
fzf_input=()
for v in "${kernels[@]}"; do
    if [ "$v" = "$running" ]; then
        fzf_input+=("  🛡️  $v   (running – will NOT be deleted)")
    else
        fzf_input+=("  $v")
    fi
done

echo "Select kernels to DELETE (space to mark, Enter to confirm):"

IFS=$'\n' selected=($(printf '%s\n' "${fzf_input[@]}" \
                    | fzf --multi --prompt="delete> " --bind=ctrl-a:toggle-all \
                          --header="Running kernel is protected.\nCTRL-A toggles all; ESC aborts.")) || {
    echo "Aborted – nothing deleted."
    exit 1
}

# Extract plain version strings, ignoring lines that mention the running kernel
to_delete=()
for line in "${selected[@]}"; do
    ver="$(awk '{print $1}' <<<"$line")"
    if [ "$ver" != "$running" ]; then
        to_delete+=("$ver")
    fi
done

if [ "${#to_delete[@]}" -eq 0 ]; then
    echo "You didn’t select anything (or only the running kernel)."
    exit 0
fi

echo
echo "You chose to delete ${#to_delete[@]} kernel(s):"
printf '  • %s\n' "${to_delete[@]}"
read -rp "Really delete these kernels? [y/N] " ans
[[ "$ans" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 1; }

for v in "${to_delete[@]}"; do
    echo "Removing $v …"
    rm -rf "/lib/modules/$v"
    rm -vf  "/boot/vmlinuz-$v" \
           "/boot/System.map-$v" \
           "/boot/config-$v" \
           "/boot/initrd.img-$v"* \
           "/boot/initramfs-$v.img" 2>/dev/null || true
done
echo "Purged ${#to_delete[@]} kernel(s)."

# Regenerate GRUB if present
if [ -e /boot/grub/grub.cfg ] || ls /boot/grub2/grub.cfg &>/dev/null; then
    echo "Updating GRUB menu …"
    if command -v grub2-mkconfig &>/dev/null; then
        grubcfg_dir=$(dirname "$(readlink -f /boot/grub*/grub.cfg | head -n1)")
        grub2-mkconfig -o "$grubcfg_dir/grub.cfg"
    elif command -v update-grub &>/dev/null; then
        update-grub
    fi
fi

echo "Done."

