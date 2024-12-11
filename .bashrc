# https://stackoverflow.com/a/69915614
# printf '\33c\e[3J'

# Bail for noninteractive session (e.g., SCP).
if [[ $- != *i* ]]; then
    return
fi

# Checking for either the presence of an SSH-related environment variable, or
# the who utility output implying a non-local login. It seems that when an X
# server is running, `who -m` doesn't return any output, which we're handling
# in awk's END line below.
# - https://unix.stackexchange.com/a/12761
REMOTE_SHELL='false'
if [[ -n "$SSH_CONNECTION" ]] ||
    [[ -v SSH_TTY ]] ||
    who -m | awk '{if ($NF ~ /\([^:]*\)/) {exit 0} else {exit 1}} END {if (NR == 0) {exit 1}}'; then
    REMOTE_SHELL='true'
fi

if [[ "$REMOTE_SHELL" == 'true' ]]; then
   cat << 'EOF'

  ╔════════════════════════════════════════════════════╗
  ║                                                    ║
  ║                   REMOTE SESSION                   ║
  ║                                                    ║
  ║     "check yo' self before you wreck yo' self"     ║
  ║                   - Ice Cube, 1992                 ║
  ║                                                    ║
  ║     "Prithee examine thy conduct,                  ║
  ║      lest thou bring about thine own undoing"      ║
  ║                   - Shakespeare, probably          ║
  ║                                                    ║
  ╚════════════════════════════════════════════════════╝

EOF
fi

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
