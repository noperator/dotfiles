#!/bin/bash

# Inspiration for lpass account switching:
# https://github.com/lastpass/lastpass-cli/issues/445#issuecomment-522701216

export LPASS_HOME="$HOME/.lpass-personal"
alias lpt='lpass status; echo LPASS_HOME=$LPASS_HOME'

# Create folders for separate LastPass accounts.
for ACCOUNT in personal work; do
    DIR="$HOME/.lpass-$ACCOUNT"
    if ! [[ -d "$DIR" ]]; then
        mkdir "$DIR"
    fi
done

# Switch LastPass account.
lpsa() {
    DIR="$HOME/.lpass-$1"
    if ! [[ -d "$DIR" ]]; then
        echo "$DIR does not exist."
    else
        export LPASS_HOME="$HOME/.lpass-$1"
        lpt
    fi
}

alias lps='lpass show -Gx'
alias lpscp='lpass show -Gxc --password'
alias lpe='lpass edit'
alias lpa='lpass add'

# Duplicate a LastPass entry. lpass doesn't let you delete some attributes from
# an existing entry, so you have to duplicate the entry while only carrying
# forward the URL, username, and password attributes, and then manually delete
# the original entry.
lpc() {
    lps "$1" | grep -E "^(Username|Password|URL):" | lpass add --non-interactive "$2"
    lps "$2"
}

# Generate a random 32-character password.
rand_alnum() {
    < /dev/urandom LC_ALL=C base64 | tr -d '/+=' | head -c "$1"
}
pwg() {
    rand_alnum 4
    < /dev/urandom LC_ALL=C tr -dc 'A-Za-z0-9!"#$%&'\''()*+,-./:;<=>?@[\]^_`{|}~' | head -c 24
    rand_alnum 4
    echo
}
pwga() {
    rand_alnum 40
    echo
}
# https://passlib.readthedocs.io/en/stable/lib/passlib.hash.sha256_crypt.html
# $5$rounds=5000$GX7BopJZJxPc/KEK$le16UF8I2Anb.rOrn22AUPWvzUETDGefUmAV8AZkGcD 
pwgh() {
    ROUNDS="$RANDOM"
    SALT="$(rand_alnum 16)"
    CHECKSUM="$(rand_alnum 43)"
    echo "\$5\$rounds=$ROUNDS\$$SALT\$$CHECKSUM"
}
