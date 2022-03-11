for FILE in $(find "$HOME/.bashrc.d/" -iname '*.sh' | sort); do
    source "$FILE"
done

for FILE in .bashrc.extra; do
    if [[ -f "$HOME/$FILE" ]]; then
        source "$HOME/$FILE"
    fi
done

# Send downloads to a temporary directory.
if [[ -d "$HOME/tmp" ]]; then
    mkdir -p "$HOME/tmp/Downloads"
    if ! [[ -L "$HOME/Downloads" ]]; then

        # Back up existing downloads directory.
        if [[ -d "$HOME/Downloads" ]]; then
            mv "$HOME/Downloads" "$HOME/Downloads.bu.$(date +%s)"
        fi
        ln -s "$HOME/tmp/Downloads" "$HOME/Downloads"
    fi
fi
