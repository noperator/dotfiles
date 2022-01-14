for FILE in $(find "$HOME/.bashrc.d/" -iname '*.sh' | sort); do
    source "$FILE"
done

for FILE in .bashrc.extra; do
    if [[ -f "$HOME/$FILE" ]]; then
        source "$HOME/$FILE"
    fi
done
