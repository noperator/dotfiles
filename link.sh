#!/bin/bash

# Link a file from the dotfiles directory to its intended location.
link() {

    # $1 is always the filename as it exists in dotfiles.
    SOURCE_DOTFILE="$HOME/dotfiles/$1"
    SOURCE_FILENAME=$(basename "$1")

    # $2 can be:
    # 1. Not provided, in which case the filename in $1 should simply be the
    #    target under $HOME.
    if [[ -z "$2" ]]; then
        TARGET="$HOME/$SOURCE_FILENAME"
    # 2. A directory name ending in '/', in which case $1 should be linked
    #    under that directory in $HOME.
    elif [[ -d "$HOME/$2" && "${2: -1}" == '/' ]]; then
        TARGET="$HOME/$2$SOURCE_FILENAME"
    # 3. An alternate name that the file should be renamed as under $HOME.
    else
        TARGET="$HOME/$2"
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
    echo "[*] Link:   $LINK_MSG$SOURCE_DOTFILE -> $TARGET"
    ln -s "$SOURCE_DOTFILE" "$TARGET"
}

# OS-agnostic files.
for FILE in \
    .bash_profile \
    .bashrc \
    .bashrc.d \
    .config \
    .gitignore_global \
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
    link .hammerspoon
    link .finicky.js
    link .skhdrc.yabai .skhdrc
    link .yabairc
    link .config/uebersicht/WidgetSettings.json 'Library/Application Support/tracesOf.Uebersicht/'
    link .config/uebersicht/widgets 'Library/Application Support/Übersicht/'
    link .config/arc/StorableKeyBindings.json 'Library/Application Support/Arc/'
    ls LaunchAgents/*.plist | while read -r FILE; do
        link "$FILE" 'Library/LaunchAgents/'
    done

    for corner in tl tr bl br; do
        defaults write com.apple.dock "wvous-$corner-corner" -int 0   # clear hot corner
        defaults write com.apple.dock "wvous-$corner-modifier" -int 0 # clear corner modifier
    done
    defaults write com.apple.dock static-only -bool true # no pinned apps in dock
    killall Dock
    defaults write com.apple.finder CreateDesktop false # no desktop icons
    killall Finder
    ;;
esac

git config --global core.excludesfile ~/.gitignore_global
