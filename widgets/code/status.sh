#!/bin/bash

DIRNAME=$(dirname "$0")

FIRST='true'
for SCRIPT in geo gateway wifi battery date; do
    [[ "$FIRST" == 'true' ]] || echo '|'
    "$DIRNAME/${SCRIPT}.sh"
    FIRST='false'
done

