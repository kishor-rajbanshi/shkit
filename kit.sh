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

# Print a formatted error message to stderr.
# Usage: _error <message>
_error() {
    if [ "$#" -ne 1 ]; then
        _error "_error: expected 1 argument, got: $#"
        return 2
    fi

    _msg=$(printf '%s' "$1")

    [ -z "$_msg" ] && return 0

    _cols="${COLUMNS:-$(stty size </dev/tty 2>/dev/null | cut -d' ' -f2)}"
    _cols="${_cols:-80}"
    _max_width=$((_cols - 4))
    [ "$_max_width" -lt 20 ] && _max_width=20

    _wrapped_msg=$(
        printf '%s\n' "$_msg" | expand | while IFS= read -r _line || [ -n "$_line" ]; do
            if [ -z "$_line" ]; then
                printf '\n'
            else
                printf '%s\n' "$_line" | fold -s -w "$_max_width"
            fi
        done
    )

    _text_width=0
    while IFS= read -r _line || [ -n "$_line" ]; do
        _line_len=${#_line}
        [ "$_line_len" -gt "$_text_width" ] && _text_width=$_line_len
    done <<-EOF
		$_wrapped_msg
	EOF

    _box_width=$((_text_width + 4))

    printf "\n\033[41m%-${_box_width}s\033[0m\n" "" >&2

    while IFS= read -r _line || [ -n "$_line" ]; do
        printf "\033[37;41m  %-${_text_width}s  \033[0m\n" "$_line" >&2
    done <<-EOF
		$_wrapped_msg
	EOF

    printf "\033[41m%-${_box_width}s\033[0m\n\n" "" >&2
}

# Print a formatted warning message to stderr.
# Usage: _warning <message>
_warning() {
    if [ "$#" -ne 1 ]; then
        _error "_warning: expected 1 argument, got: $#"
        return 2
    fi

    printf "\033[33m%s\033[0m%b" "$1" "${1:+\n}" >&2
}

# Print a formatted info message to stderr.
# Usage: _info <message>
_info() {
    if [ "$#" -ne 1 ]; then
        _error "_info: expected 1 argument, got: $#"
        return 2
    fi

    printf "\033[34m%s\033[0m%b" "$1" "${1:+\n}" >&2
}

# Print a formatted success message to stderr.
# Usage: _success <message>
_success() {
    if [ "$#" -ne 1 ]; then
        _error "_success: expected 1 argument, got: $#"
        return 2
    fi

    printf "\033[32m%s\033[0m%b" "$1" "${1:+\n}" >&2
}

# Check if two values are equal.
# Usage: _equal <value1> <value2>
_equal() {
    if [ "$#" -ne 2 ]; then
        _error "_equal: expected 2 arguments, got: $#"
        return 2
    fi

    [ "$1" = "$2" ]
}

# Check if value is a valid integer.
# Usage: _integer <value>
_integer() {
    if [ "$#" -ne 1 ]; then
        _error "_integer: expected 1 argument, got: $#"
        return 2
    fi

    case "${1#[-+]}" in
    '' | *[!0-9]*) return 1 ;;
    *) return 0 ;;
    esac
}

# Check if value is a valid float.
# Usage: _float <value>
_float() {
    if [ "$#" -ne 1 ]; then
        _error "_float: expected 1 argument, got: $#"
        return 2
    fi

    case "${1#[-+]}" in
    '' | '.' | *[!0-9.]* | *.*.*) return 1 ;;
    *.*) return 0 ;;
    *) return 1 ;;
    esac
}

# Check if value is valid number.
# Usage: _number <value>
_number() {
    if [ "$#" -ne 1 ]; then
        _error "_number: expected 1 argument, got: $#"
        return 2
    fi

    case "${1#[-+]}" in
    '' | '.' | *[!0-9.]* | *.*.*) return 1 ;;
    *) return 0 ;;
    esac
}

# Check if number is positive.
# Usage: _positive <number>
_positive() {
    if [ "$#" -ne 1 ]; then
        _error "_positive: expected 1 argument, got: $#"
        return 2
    fi

    if ! _number "$1"; then
        _error "_positive: invalid argument: expected number, got: '$1'"
        return 2
    fi

    awk "BEGIN { exit !(($1) > 0) }"
}

# Check if number is negative.
# Usage: _negative <number>
_negative() {
    if [ "$#" -ne 1 ]; then
        _error "_negative: expected 1 argument, got: $#"
        return 2
    fi

    if ! _number "$1"; then
        _error "_negative: invalid argument: expected number, got: '$1'"
        return 2
    fi

    awk "BEGIN { exit !(($1) < 0) }"
}

# Check if first number equals second.
# Usage: _eq <number1> <number2>
_eq() {
    if [ "$#" -ne 2 ]; then
        _error "_eq: expected 2 arguments, got: $#"
        return 2
    fi

    if ! _number "$1" || ! _number "$2"; then
        _error "_eq: invalid argument(s): expected numbers, got: '$1' and '$2'"
        return 2
    fi

    awk "BEGIN { exit !(($1) == ($2)) }"
}

# Check if first number is less than second.
# Usage: _lt <number1> <number2>
_lt() {
    if [ "$#" -ne 2 ]; then
        _error "_lt: expected 2 arguments, got: $#"
        return 2
    fi

    if ! _number "$1" || ! _number "$2"; then
        _error "_lt: invalid argument(s): expected numbers, got: '$1' and '$2'"
        return 2
    fi

    awk "BEGIN { exit !(($1) < ($2)) }"
}

# Check if first number is less than or equal to second.
# Usage: _le <number1> <number2>
_le() {
    if [ "$#" -ne 2 ]; then
        _error "_le: expected 2 arguments, got: $#"
        return 2
    fi

    if ! _number "$1" || ! _number "$2"; then
        _error "_le: invalid argument(s): expected numbers, got: '$1' and '$2'"
        return 2
    fi

    awk "BEGIN { exit !(($1) <= ($2)) }"
}

# Check if first number is greater than second.
# Usage: _gt <number1> <number2>
_gt() {
    if [ "$#" -ne 2 ]; then
        _error "_gt: expected 2 arguments, got: $#"
        return 2
    fi

    if ! _number "$1" || ! _number "$2"; then
        _error "_gt: invalid argument(s): expected numbers, got: '$1' and '$2'"
        return 2
    fi

    awk "BEGIN { exit !(($1) > ($2)) }"
}

# Check if first number is greater than or equal to second.
# Usage: _ge <number1> <number2>
_ge() {
    if [ "$#" -ne 2 ]; then
        _error "_ge: expected 2 arguments, got: $#"
        return 2
    fi

    if ! _number "$1" || ! _number "$2"; then
        _error "_ge: invalid argument(s): expected numbers, got: '$1' and '$2'"
        return 2
    fi

    awk "BEGIN { exit !(($1) >= ($2)) }"
}

# Escape shell glob characters.
# Usage: _glob_escape <string>
_glob_escape() {
    if [ "$#" -ne 1 ]; then
        _error "_glob_escape: expected 1 argument, got: $#"
        return 2
    fi

    printf '%s' "$1" |
        sed 's/\\/\\\\/g; s/\*/\\*/g; s/\?/\\?/g; s/\[/\\[/g; s/\]/\\]/g'
}

# Escape special characters in a sed expression.
# Usage: _sed_escape <value>
_sed_escape() {
    if [ "$#" -ne 1 ]; then
        _error "_sed_escape: expected 1 argument, got: $#"
        return 2
    fi

    printf '%s' "$1" | sed 's/[]\/$*.^|[]/\\&/g'
}

# Escape special characters in a sed replacement.
# Usage: _sed_replace_escape <value>
_sed_replace_escape() {
    if [ "$#" -ne 1 ]; then
        _error "_sed_replace_escape: expected 1 argument, got: $#"
        return 2
    fi

    printf '%s' "$1" | sed 's/[\/&]/\\&/g'
}

# Return the character length of a string.
# Usage: _str_length <string>
_str_length() {
    if [ "$#" -ne 1 ]; then
        _error "_str_length: expected 1 argument, got: $#"
        return 2
    fi

    printf "%d" "${#1}"
}

# Convert a string to lowercase.
# Usage: _str_lower <string>
_str_lower() {
    if [ "$#" -ne 1 ]; then
        _error "_str_lower: expected 1 argument, got: $#"
        return 2
    fi

    printf "%s" "$1" | tr '[:upper:]' '[:lower:]'
}

# Convert a string to uppercase.
# Usage: _str_upper <string>
_str_upper() {
    if [ "$#" -ne 1 ]; then
        _error "_str_upper: expected 1 argument, got: $#"
        return 2
    fi

    printf "%s" "$1" | tr '[:lower:]' '[:upper:]'
}

# Convert a string to lowercase-hyphenated slug format.
# Usage: _str_slug <string>
_str_slug() {
    if [ "$#" -ne 1 ]; then
        _error "_str_slug: expected 1 argument, got: $#"
        return 2
    fi

    printf "%s" "$1" |
        tr '[:upper:]' '[:lower:]' |
        tr -cs 'a-z0-9' '-' |
        sed 's/^-//;s/-$//'
}

# Remove leading and trailing whitespace from a string.
# Usage: _str_trim <string>
_str_trim() {
    if [ "$#" -ne 1 ]; then
        _error "_str_trim: expected 1 argument, got: $#"
        return 2
    fi

    printf "%s" "$1" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//'
}

# Reverse the characters of a string.
# Usage: _str_reverse <string>
_str_reverse() {
    if [ "$#" -ne 1 ]; then
        _error "_str_reverse: expected 1 argument, got: $#"
        return 2
    fi

    printf "%s" "$1" | rev 2>/dev/null ||
        printf "%s" "$1" | awk '{for(_i=length;_i>0;_i--) printf substr($0,_i,1); print ""}'
}

# Count occurrences of a substring within a string.
# Usage: _str_count <string> <substring>
_str_count() {
    if [ "$#" -ne 2 ]; then
        _error "_str_count: expected 2 arguments, got: $#"
        return 2
    fi

    printf '%s' "$1" | grep -oF "$2" | wc -l | tr -d ' '
}

# Check if a string contains a given substring.
# Usage: _str_contains <string> <substring>
_str_contains() {
    if [ "$#" -ne 2 ]; then
        _error "_str_contains: expected 2 arguments, got: $#"
        return 2
    fi

    case "$1" in
    *"$2"*) return 0 ;;
    *) return 1 ;;
    esac
}
