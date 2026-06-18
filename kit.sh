# shellcheck shell=sh

_INTERACTIVE=""
[ -t 1 ] && _INTERACTIVE="1"

# Check if any arguments were provided.
# Usage: _args "$@"
_args() {
    [ $# -gt 0 ]
}

# Return the count of provided arguments.
# Usage: _argc "$@"
_argc() {
    printf "%d" "$#"
}
