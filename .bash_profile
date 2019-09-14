for FILE in .bashrc.macos .bashrc.linux .bashrc .bashrc.extra; do
    if [[ -f "$HOME/$FILE" ]]; then
        source "$HOME/$FILE"
    fi
done
