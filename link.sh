#!/bin/bash

# Link a file from the dotfiles directory to its intended location.
link() {
    SOURCE_DOTFILE="$HOME/dotfiles/$1"
    SOURCE_FILENAME=$(basename "$1")

    # $1 is always the filename as it exists in dotfiles. $2 can be:
    # 1. Nothing, in which case the filename in $1 should be the target under
    #    $HOME.
    # 2. A directory under $HOME where the filename in $1 should be linked.
    # 3. An alternate name that the file should be renamed as under $HOME.
    LINK='[*] Link:   '
    if [[ -z "$2" ]]; then
        LINK="$LINK$SOURCE_DOTFILE -> \$HOME/$SOURCE_FILENAME"
        TARGET="$HOME/$SOURCE_FILENAME"
    else
        if [[ -d "$HOME/$2" ]]; then
            LINK="$LINK$SOURCE_DOTFILE -> \$HOME/$2/$SOURCE_FILENAME"
            TARGET="$HOME/$2/$SOURCE_FILENAME"
        else
            LINK="$LINK$SOURCE_DOTFILE -> \$HOME/$2"
            TARGET="$HOME/$2"
        fi
    fi

    # Remove existing symlinks. Otherwise, backup existing files.
    if [[ -L "$TARGET" ]]; then
        echo "[-] Remove: $TARGET@"
        rm "$TARGET"
    elif [[ -e "$TARGET" ]]; then
        BACKUP="$TARGET.bu.$(date '+%s')"
        echo "[+] Backup: $TARGET -> $BACKUP"
        mv "$TARGET" "$BACKUP"
    fi

    # Finally, link the dotfile to its intended target.
    echo "$LINK"
    ln -s "$SOURCE_DOTFILE" "$TARGET"
}

# OS-agnostic files.
for FILE in \
    .bash_profile \
    .bashrc \
    .bashrc.d \
    .config \
    .hushlogin \
    .inputrc \
    .inputrc.tmux \
    .ipython \
    .jq \
    .local \
    .tmux.conf \
    .vimrc \
    nvim; do
    link "$FILE"
done

# OS-specific files.
case "$OSTYPE" in
'linux-gnu'*)
    for FILE in \
        .asoundrc \
        .xinitrc \
        .Xresources \
        .XCompose; do
        link "$FILE"
    done
    ;;
'darwin'*)
    link .skhdrc.yabai .skhdrc
    link .yabairc
    link .config/uebersicht 'Library/Application Support/Übersicht/widgets'
    for PROFILE in $(ls "$HOME/Library/Application Support/Firefox/Profiles/"); do
        link .config/firefox/user.js "Library/Application Support/Firefox/Profiles/$PROFILE"
    done
    ;;
esac
