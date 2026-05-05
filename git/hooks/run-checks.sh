#!/bin/sh
# Usage: run-checks.sh [--warn | --block | --all]
# Default: --all
MODE="${1:---all}"

# Colors (no-op if not a terminal)
if [ -t 1 ]; then
    RED='\033[0;31m'
    YELLOW='\033[0;33m'
    BOLD='\033[1m'
    RESET='\033[0m'
else
    RED='' YELLOW='' BOLD='' RESET=''
fi

# header() { printf "\n${BOLD}${RED}FAIL [%s]${RESET}\n" "$1"; }
hint() { printf "${YELLOW}  Fix: %s${RESET}\n" "$1"; }

# Check required tools
missing=0
check_tool() {
    command -v "$1" >/dev/null 2>&1 && return
    printf "${YELLOW}WARNING: %s not installed. %s${RESET}\n" "$1" "$2"
    missing=1
}
check_tool shfmt "Install: brew install shfmt  OR  go install mvdan.cc/sh/v3/cmd/shfmt@latest"
check_tool shellcheck "Install: brew install shellcheck  OR  apt install shellcheck"
check_tool goimports "Install: go install golang.org/x/tools/cmd/goimports@latest"
check_tool golangci-lint "Install: brew install golangci-lint  OR  see https://golangci-lint.run/usage/install/"
if [ "$missing" -eq 1 ]; then
    [ "$MODE" = "--block" ] || [ "$MODE" = "--all" ] && exit 1
    exit 0
fi

# Determine file set
case "$MODE" in
--warn)
    FILES=$(git diff --cached --name-only --diff-filter=ACM)
    ;;
--block)
    REMOTE=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)
    if [ -n "$REMOTE" ]; then
        FILES=$(git diff --name-only --diff-filter=ACM "$REMOTE"...HEAD)
    else
        FILES=$(git diff --name-only --diff-filter=ACM \
            "$(git rev-list --max-parents=0 HEAD)" HEAD)
    fi
    ;;
--all)
    FILES=$(git ls-files)
    ;;
*)
    echo "Usage: run-checks.sh [--warn | --block | --all]"
    exit 1
    ;;
esac

SH_FILES=$(echo "$FILES" | grep '\.sh$')
GO_FILES=$(echo "$FILES" | grep '\.go$')

TMP=$(mktemp -d)
cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT

# shfmt
if [ -n "$SH_FILES" ]; then
    (
        # shellcheck disable=SC2086
        out=$(shfmt -i 4 -l $SH_FILES)
        if [ -n "$out" ]; then
            echo "$out" | sed 's/^/  /'
            hint "shfmt -i 4 -w $(echo "$out" | tr '\n' ' ')"
            exit 1
        fi
    ) >"$TMP/shfmt.out" 2>&1
    echo $? >"$TMP/shfmt.exit" &
fi

# shellcheck
if [ -n "$SH_FILES" ]; then
    (
        # shellcheck disable=SC2086
        shellcheck $SH_FILES
    ) >"$TMP/shellcheck.out" 2>&1
    echo $? >"$TMP/shellcheck.exit" &
fi

# goimports
if [ -n "$GO_FILES" ]; then
    (
        # shellcheck disable=SC2086
        out=$(goimports -l $GO_FILES)
        if [ -n "$out" ]; then
            echo "$out" | sed 's/^/  /'
            hint "goimports -w $(echo "$out" | tr '\n' ' ')"
            exit 1
        fi
    ) >"$TMP/goimports.out" 2>&1
    echo $? >"$TMP/goimports.exit" &
fi

# golangci-lint
if [ -n "$GO_FILES" ]; then
    if git rev-parse --show-toplevel >/dev/null 2>&1 && [ -f "$(git rev-parse --show-toplevel)/go.mod" ]; then
        (
            golangci-lint run --config ~/.golangci.yml
        ) >"$TMP/golangci.out" 2>&1
        echo $? >"$TMP/golangci.exit" &
    fi
fi

wait

# Collect results
OUTPUT="$TMP/final.out"
failed=0
first=1
for check in shfmt shellcheck goimports golangci; do
    [ -f "$TMP/$check.exit" ] || continue
    code=$(cat "$TMP/$check.exit")
    out=$(cat "$TMP/$check.out")
    if [ "$code" -ne 0 ]; then
        [ "$first" -eq 1 ] && first=0 || printf "\n" >>"$OUTPUT"
        printf "${BOLD}${RED}FAIL [%s]${RESET}\n\n" "$check" >>"$OUTPUT"
        [ -n "$out" ] && printf "%s\n" "$out" >>"$OUTPUT"
        failed=1
    else
        [ "$first" -eq 1 ] && first=0 || printf "\n" >>"$OUTPUT"
        printf "${BOLD}PASS [%s]${RESET}\n" "$check" >>"$OUTPUT"
    fi
done

cat -s "$OUTPUT"

if [ "$failed" -eq 1 ]; then
    [ "$MODE" = "--warn" ] && exit 0
    exit 1
fi

exit 0
