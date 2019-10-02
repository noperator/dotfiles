for FILE in .bashrc; do
    if [[ -f "$HOME/$FILE" ]]; then
        source "$HOME/$FILE"
    fi
done
