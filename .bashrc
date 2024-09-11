# https://stackoverflow.com/a/69915614
# printf '\33c\e[3J'

for FILE in $(find "$HOME/.bashrc.d/" -iname '*.sh' | sort); do
    source "$FILE"
done

# Extra stuff that's not committed to version control.
for FILE in .bashrc.extra; do
    if [[ -f "$HOME/$FILE" ]]; then
        source "$HOME/$FILE"
    fi
done

# Create automatic user-specific temporary directory (à la `libpam-tmpdir`, but
# for macOS).
# - https://apple.stackexchange.com/a/194651
# - https://www.techjunkie.com/how-to-create-a-4gbs-ram-disk-in-mac-os-x/
HOME_TMPDIR="$HOME/tmp"
if [[ "$OSTYPE" == 'darwin'* ]]; then
    if ! mount | grep -q "$HOME_TMPDIR"; then
        mkdir -p "$HOME_TMPDIR"
        SECTORS=$((4 * 1024 * 2048)) # 4 GB
        DEV_FILE=$(hdiutil attach -nomount "ram://$SECTORS" | tr -d '[:space:]')
        newfs_hfs "$DEV_FILE"
        mount -t hfs "$DEV_FILE" "$HOME_TMPDIR"
    fi
fi

# Send downloads to the temporary directory.
if [[ -d "$HOME_TMPDIR" ]]; then
    mkdir -p "$HOME_TMPDIR/Downloads"
    if ! [[ -L "$HOME/Downloads" ]]; then

        # Back up existing downloads directory.
        if [[ -d "$HOME/Downloads" ]]; then
            mv "$HOME/Downloads" "$HOME/Downloads.bu.$(date +%s)"
        fi
        ln -s "$HOME_TMPDIR/Downloads" "$HOME/Downloads"
    fi
fi

export PATH="$PATH:/Users/calebgross/.bfrtk/bin"
. "$HOME/.cargo/env"
