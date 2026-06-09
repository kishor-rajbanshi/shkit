#!/bin/sh

test_dir="$(cd "$(dirname "$0")" && pwd)"

. "$test_dir/../kit.sh"

passed=0
failed=0

pass() {
    label="$1"
    printf '\033[32m  PASS: %s\033[0m\n' "$label" >&2
    passed=$((passed + 1))
}

fail() {
    label="$1"
    message="$2"
    printf '\033[31m  FAIL: %s\n    %s\n\033[0m' "$label" "$message" >&2
    failed=$((failed + 1))
}

result() {
    printf "\n\033[32mPASSED: %b\n\033[31mFAILED: %s\033[0m\n" \
        "$passed" "$failed" >&2
    [ "$failed" -eq 0 ]
}

assert_true() {
    if eval "$*" >/dev/null 2>&1; then
        pass "$*"
    else
        fail "$*" "expected true (exit 0), got non-zero"
    fi
}

assert_false() {
    if eval "$*" >/dev/null 2>&1; then
        fail "$*" "expected false (non-zero exit), got 0"
    else
        pass "$*"
    fi
}

assert_equal() {
    label="$1"
    expected="$2"

    actual="$($label 2>/dev/null)"

    if [ "$expected" = "$actual" ]; then
        pass "$label"
    else
        fail "$label" "expected: '$expected'  actual: '$actual'"
    fi
}

assert_not_equal() {
    label="$1"
    expected="$2"

    actual="$($label 2>/dev/null)"

    if [ "$expected" != "$actual" ]; then
        pass "$label"
    else
        fail "$label" "expected: '$expected'  actual: '$actual'"
    fi
}

printf '\n\033[1;44m Running tests... \033[0m\n\n' >&2
. "$test_dir/test.sh"

result
