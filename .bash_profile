for FILE in .bashrc.extra .bashrc; do
    if [[ -f "$HOME/$FILE" ]]; then
        source "$HOME/$FILE"
    fi
done
