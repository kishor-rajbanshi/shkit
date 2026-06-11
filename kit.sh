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
    _msg="$1"

    if [ "$#" -ne 1 ]; then
        _error "_error: expected 1 argument, got: $#"
        return 2
    fi

    _len=$((${_msg:+${#_msg}+4}))

    printf "${_msg:+\n}\033[41m%-${_len}s\033[0m${_msg:+\n}" "" >&2
    printf "\033[37;41m${_msg:+  }%s${_msg:+  }\033[0m${_msg:+\n}" "$_msg" >&2
    printf "\033[41m%-${_len}s\033[0m${_msg:+\n\n}" "" >&2
}

# Print a formatted warning message to stderr.
# Usage: _warning <message>
_warning() {
    _msg="$1"

    if [ "$#" -ne 1 ]; then
        _error "_warning: expected 1 argument, got: $#"
        return 2
    fi

    printf "\033[33m%s\033[0m${_msg:+\n}" "$_msg" >&2
}

# Print a formatted info message to stderr.
# Usage: _info <message>
_info() {
    _msg="$1"

    if [ "$#" -ne 1 ]; then
        _error "_info: expected 1 argument, got: $#"
        return 2
    fi

    printf "\033[34m%s\033[0m${_msg:+\n}" "$_msg" >&2
}

# Print a formatted success message to stderr.
# Usage: _success <message>
_success() {
    _msg="$1"

    if [ "$#" -ne 1 ]; then
        _error "_success: expected 1 argument, got: $#"
        return 2
    fi

    printf "\033[32m%s\033[0m${_msg:+\n}" "$_msg" >&2
}

# Check if two values are equal.
# Usage: _equal <value1> <value2>
_equal() {
    _val1="$1"
    _val2="$2"

    if [ "$#" -ne 2 ]; then
        _error "_equal: expected 2 arguments, got: $#"
        return 2
    fi

    [ "$_val1" = "$_val2" ]
}

# Check if value is a valid integer.
# Usage: _integer <value>
_integer() {
    _val="$1"

    if [ "$#" -ne 1 ]; then
        _error "_integer: expected 1 argument, got: $#"
        return 2
    fi

    case "${_val#[-+]}" in
    '' | *[!0-9]*) return 1 ;;
    *) return 0 ;;
    esac
}

# Check if value is a valid float.
# Usage: _float <value>
_float() {
    _val="$1"

    if [ "$#" -ne 1 ]; then
        _error "_float: expected 1 argument, got: $#"
        return 2
    fi

    # case "${_val#[-+]}" in
    # '' | '.' | *[!0-9.]* | *.*.*) return 1 ;;
    # *.*) return 0 ;;
    # *) return 1 ;;
    # esac

    case "${_val#[-+]}" in
    [0-9]*.[0-9]*) [ "${_val#[-+]}" != "." ] ;;
    *) return 1 ;;
    esac
}

# Check if value is valid number.
# Usage: _number <value>
_number() {
    _val="$1"

    if [ "$#" -ne 1 ]; then
        _error "_number: expected 1 argument, got: $#"
        return 2
    fi

    case "${_val#[-+]}" in
    '' | '.' | *[!0-9.]* | *.*.*) return 1 ;;
    *) return 0 ;;
    esac
}

# Check if number is positive.
# Usage: _positive <number>
_positive() {
    _num="$1"

    if [ "$#" -ne 1 ]; then
        _error "_positive: expected 1 argument, got: $#"
        return 2
    fi

    if ! _number "$_num"; then
        _error "_positive: invalid argument: expected number, got: '$_num'"
        return 2
    fi

    awk "BEGIN { exit !(($_num) > 0) }"
}

# Check if number is negative.
# Usage: _negative <number>
_negative() {
    _num="$1"

    if [ "$#" -ne 1 ]; then
        _error "_negative: expected 1 argument, got: $#"
        return 2
    fi

    if ! _number "$_num"; then
        _error "_negative: invalid argument: expected number, got: '$_num'"
        return 2
    fi

    awk "BEGIN { exit !(($_num) < 0) }"
}

# Check if first number equals second.
# Usage: _eq <number1> <number2>
_eq() {
    _num1="$1"
    _num2="$2"

    if [ "$#" -ne 2 ]; then
        _error "_eq: expected 2 arguments, got: $#"
        return 2
    fi

    if ! _number "$_num1" || ! _number "$_num2"; then
        _error "_eq: invalid argument(s): expected numbers, got: '$_num1' and '$_num2'"
        return 2
    fi

    awk "BEGIN { exit !(($_num1) == ($_num2)) }"
}

# Check if first number is less than second.
# Usage: _lt <number1> <number2>
_lt() {
    _num1="$1"
    _num2="$2"

    if [ "$#" -ne 2 ]; then
        _error "_lt: expected 2 arguments, got: $#"
        return 2
    fi

    if ! _number "$_num1" || ! _number "$_num2"; then
        _error "_lt: invalid argument(s): expected numbers, got: '$_num1' and '$_num2'"
        return 2
    fi

    awk "BEGIN { exit !(($_num1) < ($_num2)) }"
}

# Check if first number is less than or equal to second.
# Usage: _le <number1> <number2>
_le() {
    _num1="$1"
    _num2="$2"

    if [ "$#" -ne 2 ]; then
        _error "_le: expected 2 arguments, got: $#"
        return 2
    fi

    if ! _number "$_num1" || ! _number "$_num2"; then
        _error "_le: invalid argument(s): expected numbers, got: '$_num1' and '$_num2'"
        return 2
    fi

    awk "BEGIN { exit !(($_num1) <= ($_num2)) }"
}

# Check if first number is greater than second.
# Usage: _gt <number1> <number2>
_gt() {
    _num1="$1"
    _num2="$2"

    if [ "$#" -ne 2 ]; then
        _error "_gt: expected 2 arguments, got: $#"
        return 2
    fi

    if ! _number "$_num1" || ! _number "$_num2"; then
        _error "_gt: invalid argument(s): expected numbers, got: '$_num1' and '$_num2'"
        return 2
    fi

    awk "BEGIN { exit !(($_num1) > ($_num2)) }"
}

# Check if first number is greater than or equal to second.
# Usage: _ge <number1> <number2>
_ge() {
    _num1="$1"
    _num2="$2"

    if [ "$#" -ne 2 ]; then
        _error "_ge: expected 2 arguments, got: $#"
        return 2
    fi

    if ! _number "$_num1" || ! _number "$_num2"; then
        _error "_ge: invalid argument(s): expected numbers, got: '$_num1' and '$_num2'"
        return 2
    fi

    awk "BEGIN { exit !(($_num1) >= ($_num2)) }"
}

# Escape shell glob characters.
# Usage: _glob_escape <string>
_glob_escape() {
    _str="$1"

    if [ "$#" -ne 1 ]; then
        _error "_glob_escape: expected 1 argument, got: $#"
        return 2
    fi

    printf '%s' "$_str" |
        sed 's/\\/\\\\/g; s/\*/\\*/g; s/\?/\\?/g; s/\[/\\[/g; s/\]/\\]/g'
}

# Escape special characters in a sed expression.
# Usage: _sed_escape <value>
_sed_escape() {
    _val="$1"

    if [ "$#" -ne 1 ]; then
        _error "_sed_escape: expected 1 argument, got: $#"
        return 2
    fi

    printf '%s' "$_val" | sed 's/[]\/$*.^|[]/\\&/g'
}

# Escape special characters in a sed replacement.
# Usage: _sed_replace_escape <value>
_sed_replace_escape() {
    _val="$1"

    if [ "$#" -ne 1 ]; then
        _error "_sed_replace_escape: expected 1 argument, got: $#"
        return 2
    fi

    printf '%s' "$_val" | sed 's/[\/&]/\\&/g'
}

# Return the character length of a string.
# Usage: _str_length <string>
_str_length() {
    _str="$1"

    if [ "$#" -ne 1 ]; then
        _error "_str_length: expected 1 argument, got: $#"
        return 2
    fi

    printf "%d" "${#_str}"
}

# Convert a string to lowercase.
# Usage: _str_lower <string>
_str_lower() {
    _str="$1"

    if [ "$#" -ne 1 ]; then
        _error "_str_lower: expected 1 argument, got: $#"
        return 2
    fi

    printf "%s" "$_str" | tr '[:upper:]' '[:lower:]'
}

# Convert a string to uppercase.
# Usage: _str_upper <string>
_str_upper() {
    _str="$1"

    if [ "$#" -ne 1 ]; then
        _error "_str_upper: expected 1 argument, got: $#"
        return 2
    fi

    printf "%s" "$_str" | tr '[:lower:]' '[:upper:]'
}

# Convert a string to lowercase-hyphenated slug format.
# Usage: _str_slug <string>
_str_slug() {
    _str="$1"

    if [ "$#" -ne 1 ]; then
        _error "_str_slug: expected 1 argument, got: $#"
        return 2
    fi

    printf "%s" "$_str" |
        tr '[:upper:]' '[:lower:]' |
        tr -cs 'a-z0-9' '-' |
        sed 's/^-//;s/-$//'
}

# Remove leading and trailing whitespace from a string.
# Usage: _str_trim <string>
_str_trim() {
    _str="$1"

    if [ "$#" -ne 1 ]; then
        _error "_str_trim: expected 1 argument, got: $#"
        return 2
    fi

    printf "%s" "$_str" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//'
}

# Reverse the characters of a string.
# Usage: _str_reverse <string>
_str_reverse() {
    _str="$1"

    if [ "$#" -ne 1 ]; then
        _error "_str_reverse: expected 1 argument, got: $#"
        return 2
    fi

    printf "%s" "$_str" | rev 2>/dev/null ||
        printf "%s" "$_str" | awk '{for(i=length;i>0;i--) printf substr($0,i,1); print ""}'
}

# Count occurrences of a substring within a string.
# Usage: _str_count <string> <substring>
_str_count() {
    _str="$1"
    _substr="$2"

    if [ "$#" -ne 2 ]; then
        _error "_str_count: expected 2 arguments, got: $#"
        return 2
    fi

    printf '%s' "$_str" | grep -oF "$_substr" | wc -l | tr -d ' '
}

# Check if a string contains a given substring.
# Usage: _str_contains <string> <substring>
_str_contains() {
    _str="$1"
    _substr="$2"

    if [ "$#" -ne 2 ]; then
        _error "_str_contains: expected 2 arguments, got: $#"
        return 2
    fi

    case "$_str" in
    *"$_substr"*) return 0 ;;
    *) return 1 ;;
    esac
}

# Repeat a string a given number of times.
# Usage: _str_repeat <string> <count>
_str_repeat() {
    _str="$1"
    _cnt="$2"

    if [ "$#" -ne 2 ]; then
        _error "_str_repeat: expected 2 arguments, got: $#"
        return 2
    fi

    if ! _integer "$_cnt" || _negative "$_cnt"; then
        _error "_str_repeat: invalid argument: COUNT: expected non-negative integer, got: '$_cnt'"
        return 2
    fi

    _i=0
    while [ "$_i" -lt "$_cnt" ]; do
        printf '%s' "$_str"
        _i=$((_i + 1))
    done
}

# Check if a string starts with a given substring.
# Usage: _str_starts_with <string> <substring>
_str_starts_with() {
    _str="$1"
    _substr="$2"

    if [ "$#" -ne 2 ]; then
        _error "_str_starts_with: expected 2 arguments, got: $#"
        return 2
    fi

    case "$_str" in
    "$_substr"*) return 0 ;;
    *) return 1 ;;
    esac
}

# Check if a string ends with a given substring.
# Usage: _str_ends_with <string> <substring>
_str_ends_with() {
    _str="$1"
    _substr="$2"

    if [ "$#" -ne 2 ]; then
        _error "_str_ends_with: expected 2 arguments, got: $#"
        return 2
    fi

    case "$_str" in
    *"$_substr") return 0 ;;
    *) return 1 ;;
    esac
}

# Replace all occurrences of a substring within a string.
# Usage: _str_replace <string> <search> <replace>
_str_replace() {
    _str="$1"
    _search="$2"
    _repl="$3"

    if [ "$#" -ne 3 ]; then
        _error "_str_replace: expected 3 arguments, got: $#"
        return 2
    fi

    if [ -z "$_search" ]; then
        _error "_str_replace: invalid argument: SEARCH: expected string, got: '$_search'"
        return 2
    fi

    _search=$(_sed_escape "$_search")
    _repl=$(_sed_replace_escape "$_repl")

    printf "%s" "$_str" | sed "s|$_search|$_repl|g"
}

# Pad a string on the left to a given width with a fill character.
# Usage: _str_pad_left <string> <width> [char]
_str_pad_left() {
    _str="$1"
    _width="$2"
    _char="${3:- }"

    if [ "$#" -lt 2 ]; then
        _error "_str_pad_left: expected at least 2 arguments, got: $#"
        return 2
    fi

    if [ "$#" -gt 3 ]; then
        _error "_str_pad_left: expected at most 3 arguments, got: $#"
        return 2
    fi

    if ! _integer "$_width" || _negative "$_width"; then
        _error "_str_pad_left: invalid argument: WIDTH: expected non-negative integer, got: '$_width'"
        return 2
    fi

    if [ "${#_char}" -ne 1 ]; then
        _error "_str_pad_left: invalid argument: CHAR: expected 1 character, got: '$_char'"
        return 2
    fi

    _pad=$(printf '%*s' "$((_width - ${#_str} < 0 ? 0 : _width - ${#_str}))" '' | tr ' ' "$_char")

    printf '%s%s' "$_pad" "$_str"
}

# Pad a string on the right to a given width with a fill character.
# Usage: _str_pad_right <string> <width> [char]
_str_pad_right() {
    _str="$1"
    _width="$2"
    _char="${3:- }"

    if [ "$#" -lt 2 ]; then
        _error "_str_pad_right: expected at least 2 arguments, got: $#"
        return 2
    fi

    if [ "$#" -gt 3 ]; then
        _error "_str_pad_right: expected at most 3 arguments, got: $#"
        return 2
    fi

    if ! _integer "$_width" || _negative "$_width"; then
        _error "_str_pad_right: invalid argument: WIDTH: expected non-negative integer, got: '$_width'"
        return 2
    fi

    if [ "${#_char}" -ne 1 ]; then
        _error "_str_pad_right: invalid argument: CHAR: expected 1 character, got: '$_char'"
        return 2
    fi

    _pad=$(printf '%*s' "$((_width - ${#_str} < 0 ? 0 : _width - ${#_str}))" '' | tr ' ' "$_char")

    printf '%s%s' "$_str" "$_pad"
}

# Print ANSI escape sequence for given attributes.
# Attributes: reset|bold|dim|italic|underline  fg: fg_<color>  bg: bg_<color>
# Colors: black|red|green|yellow|blue|magenta|cyan|white
# Usage: _ansi <attribute> [attribute2 ...]
_ansi() {
    if [ "$#" -eq 0 ]; then
        _error "_ansi: expected at least 1 argument, got: $#"
        return 2
    fi

    _styles=""
    _fg=""
    _bg=""

    for _attr in "$@"; do
        case "$_attr" in
        reset) _styles="${_styles:+$_styles;}0" ;;
        bold) _styles="${_styles:+$_styles;}1" ;;
        dim) _styles="${_styles:+$_styles;}2" ;;
        italic) _styles="${_styles:+$_styles;}3" ;;
        underline) _styles="${_styles:+$_styles;}4" ;;
        fg_black) _fg="30" ;;
        fg_red) _fg="31" ;;
        fg_green) _fg="32" ;;
        fg_yellow) _fg="33" ;;
        fg_blue) _fg="34" ;;
        fg_magenta) _fg="35" ;;
        fg_cyan) _fg="36" ;;
        fg_white) _fg="37" ;;
        bg_black) _bg="40" ;;
        bg_red) _bg="41" ;;
        bg_green) _bg="42" ;;
        bg_yellow) _bg="43" ;;
        bg_blue) _bg="44" ;;
        bg_magenta) _bg="45" ;;
        bg_cyan) _bg="46" ;;
        bg_white) _bg="47" ;;
        *)
            _error "_ansi: invalid argument: ATTRIBUTE: '$_attr'"
            return 2
            ;;
        esac
    done

    [ "$_INTERACTIVE" ] &&
        printf "%b" "\033[${_styles}${_styles:+${_fg:+;}}${_fg}${_fg:+${_bg:+;}}${_bg}m"
}

# Check if a command exists on the system.
# Usage: _exists <command>
_exists() {
    _cmd="$1"

    if [ "$#" -ne 1 ]; then
        _error "_exists: expected 1 argument, got: $#"
        return 2
    fi

    if eval type type >/dev/null 2>&1; then
        eval type "$_cmd" >/dev/null 2>&1
    elif command >/dev/null 2>&1; then
        command -v "$_cmd" >/dev/null 2>&1
    else
        which "$_cmd" >/dev/null 2>&1
    fi

    return $?
}

# Check if the command(s) exist in the system.
# Usage: _require <command> [command2 ...]
_require() {
    if [ "$#" -lt 1 ]; then
        _error "_require: expected at least 1 argument, got: $#"
        return 2
    fi

    _missing=""

    for _cmd in "$@"; do
        if ! _exists "$_cmd"; then
            _missing="$_missing $_cmd"
        fi
    done

    if [ -n "$_missing" ]; then
        _error "Required command(s) not found:"

        for _cmd in $_missing; do
            printf " - \033[31m%s\033[0m\n" "$_cmd" >&2
        done

        printf "\n"
        exit 127
    fi
}

# Check if file descriptor is a terminal.
# Usage: _tty <fd>
_tty() {
    _fd="$1"

    if [ "$#" -ne 1 ]; then
        _error "_tty: expected 1 argument, got: $#"
        return 2
    fi

    [ -t "$_fd" ]
}

# Check if current user is root.
# Usage: _root
_root() {
    if [ "$#" -ne 0 ]; then
        _error "_root: expected 0 arguments, got: $#"
        return 2
    fi

    [ "$(id -u)" = "0" ]
}

# Print a newline
# Usage: _nl
_nl() {
    if [ "$#" -ne 0 ]; then
        _error "_nl: expected 0 arguments, got: $#"
        return 2
    fi

    printf '\n'
}

# Print spaces based on given indentation width (default 4).
# Usage: _indent [width]
_indent() {
    _width="${1:-4}"

    if [ "$#" -gt 1 ]; then
        _error "_indent: expected at most 1 argument, got: $#"
        return 2
    fi

    if ! _integer "$_width" || _negative "$_width"; then
        _error "_indent: invalid argument: WIDTH: expected non-negative integer, got: '$_width'"
        return 2
    fi

    printf '%*s' "$_width" ''
}

# Print an error message and exit with non-zero status.
# Usage: _die [-m <message>] [-c <exit_code>]
_die() {
    _msg="Fatal error"
    _code=1

    while getopts ':m:c:' _opt; do
        case "$_opt" in
        m) _msg="$OPTARG" ;;
        c) _code="$OPTARG" ;;
        :)
            _error "_die: option requires an argument: '-$OPTARG'"
            exit 2
            ;;
        ?)
            _error "_die: invalid option: '-$OPTARG'"
            exit 2
            ;;
        esac
    done

    shift $((OPTIND - 1))

    if [ "$#" -ne 0 ]; then
        _error "_die: unexpected argument(s): $*"
        exit 2
    fi

    if ! _integer "$_code" || _negative "$_code"; then
        _error "_die: invalid argument: -c: expected non-negative integer, got: '$_code'"
        exit 2
    fi

    _error "$_msg"
    exit "$_code"
}

# Check if value is empty.
# Usage: _empty <value>
_empty() {
    _val="$1"

    if [ "$#" -ne 1 ]; then
        _error "_empty: expected 1 argument, got: $#"
        return 2
    fi

    [ -z "$_val" ]
}

# Check if value contains only whitespace.
# Usage: _blank <value>
_blank() {
    _val="$1"

    if [ "$#" -ne 1 ]; then
        _error "_blank: expected 1 argument, got: $#"
        return 2
    fi

    case "$_val" in
    '' | *[![:space:]]*) return 1 ;;
    *) return 0 ;;
    esac
}

# Set a trap for the specified signal(s).
# Usage: _trap <command> <SIGNAL> [SIGNAL2 ...]
# Note: Uses § as internal delimiter — avoid using it in trap commands.
_trap() {
    _cmd="$1"

    if [ "$#" -lt 2 ]; then
        _error "_trap: expected at least 2 arguments, got: $#"
        return 2
    fi

    if [ -z "$_cmd" ]; then
        _error "_trap: invalid argument: COMMAND: expected non-empty string, got: '$_cmd'"
        return 2
    fi

    if _str_contains "$_cmd" '§'; then
        _error "_trap: invalid argument: COMMAND: contains reserved character: '§'"
        return 2
    fi

    shift

    for _sig in "$@"; do
        _sig=$(printf "%s" "$_sig" | tr '[:lower:]' '[:upper:]')

        if ! trap ':' "$_sig" 2>/dev/null; then
            _error "_trap: invalid argument: unknown signal: '$_sig'"
            return 2
        fi

        eval "_existing=\${_trap_registry_${_sig}}"

        if [ -z "${_existing:-}" ]; then
            eval "_trap_registry_${_sig}=\"\${_cmd}\""
        else
            eval "_trap_registry_${_sig}=\"\${_existing}§\${_cmd}\""
        fi

        eval "trap '_trap_run ${_sig}' ${_sig}"
    done
}

# Run the commands associated with the specified signal(s).
# Usage: _trap_run <SIGNAL> [SIGNAL2 ...]
_trap_run() {
    if [ "$#" -lt 1 ]; then
        _error "_trap_run: expected at least 1 argument, got: $#"
        return 2
    fi

    for _sig in "$@"; do
        _sig=$(printf "%s" "$_sig" | tr '[:lower:]' '[:upper:]')

        eval "_cmds=\${_trap_registry_${_sig}}"

        _cmds=$(printf '%s\n' "${_cmds}" | tr '§' ';')
        _error=$(eval "$_cmds" 2>&1 1>&3)
        _status=$?

        if [ "$_status" -ne 0 ]; then
            _error "_trap: invalid argument: COMMAND: $(
                printf '%s' "$_error" |
                    sed 's/^[^:]*: eval: line [0-9]*: *//' |
                    tr '\n' '|' |
                    sed 's/|/ | /g; s/[[:space:]]*$//'
            )"
            return 2
        fi

    done
} 3>&1

# Reset traps for the specified signal(s) or all if no signal is provided.
# Usage: _trap_reset [SIGNAL [SIGNAL2 ...]]
_trap_reset() {
    if [ "$#" -eq 0 ]; then
        for _var in $(set | grep '^_trap_registry_' | cut -d'=' -f1); do
            _sig="${_var#_trap_registry_}"
            trap - "$_sig" 2>/dev/null
            unset "$_var"
        done
    else
        for _sig in "$@"; do
            _sig=$(printf "%s" "$_sig" | tr '[:lower:]' '[:upper:]')
            trap - "$_sig" 2>/dev/null
            eval "unset _trap_registry_${_sig}"
        done
    fi
}

# Return the current terminal column width.
# Usage: _terminal_width
# shellcheck disable=SC2120
_terminal_width() {
    if [ "$#" -ne 0 ]; then
        _error "_terminal_width: expected 0 arguments, got: $#"
        return 2
    fi

    if _exists stty && _exists cut; then
        stty size </dev/tty 2>/dev/null | cut -d' ' -f2
    elif _exists tput; then
        tput cols 2>/dev/null
    elif [ "$COLUMNS" ]; then
        printf '%s' "$COLUMNS"
    else
        _error "_terminal_width: failed to determine terminal width"
        return 1
    fi
}

# Print a line of a specified character and length.
# Usage: _line [-c <char>] [-w <width>]
_line() {
    _char="-"
    _width=$(_terminal_width 2>/dev/null || printf "%d" 80)

    while getopts ':c:w:' _opt; do
        case "$_opt" in
        c) _char="$OPTARG" ;;
        w) _width="$OPTARG" ;;
        :)
            _error "_line: option requires an argument: '-$OPTARG'"
            return 2
            ;;
        ?)
            _error "_line: invalid option: '-$OPTARG'"
            return 2
            ;;
        esac
    done

    shift $((OPTIND - 1))

    if [ "$#" -ne 0 ]; then
        _error "_line: unexpected argument(s): $*"
        return 2
    fi

    if [ "${#_char}" -ne 1 ]; then
        _error "_line: invalid argument: -c: expected 1 character, got: '$_char'"
        return 2
    fi

    if ! _integer "$_width" || _negative "$_width"; then
        _error "_line: invalid argument: -w: expected non-negative integer, got: '$_width'"
        return 2
    fi

    _i=0
    while [ "$_i" -lt "$_width" ]; do
        printf '%s' "$_char"
        _i=$((_i + 1))
    done

    printf '\n'
}

# Check if the value is a valid URL.
# Usage: _url <url>
_url() {
    _url="$1"

    if [ "$#" -ne 1 ]; then
        _error "_url: expected 1 argument, got: $#"
        return 2
    fi

    case "$_url" in
    http://* | https://*) ;;
    *) return 1 ;;
    esac

    case "$_url" in
    http:// | https://) return 1 ;;
    esac

    case "$_url" in
    *[[:space:]]* | *..*) return 1 ;;
    esac

    return 0
}

# Check if the value is a valid ip address
# Usage: _ip <ip>
_ip() {
    _ip="$1"

    if [ "$#" -ne 1 ]; then
        _error "_ip: expected 1 argument, got: $#"
        return 2
    fi

    case "$_ip" in
    *. | .*) return 1 ;;
    *.*.*.*) ;;
    *) return 1 ;;
    esac

    # shellcheck disable=SC2046
    set -- $(printf '%s' "$_ip" | tr '.' ' ')

    [ $# -eq 4 ] || return 1

    for _octet in "$@"; do
        _integer "$_octet" || return 1

        case "$_octet" in
        0[0-9]*) return 1 ;;
        esac

        [ "$_octet" -ge 0 ] && [ "$_octet" -le 255 ] || return 1
    done

    return 0
}

# Check if the value is a valid email address.
# Usage: _email <email>
_email() {
    _email="$1"

    if [ "$#" -ne 1 ]; then
        _error "_email: expected 1 argument, got: $#"
        return 2
    fi

    case "$_email" in
    *@*.*) ;;
    *) return 1 ;;
    esac

    case "$_email" in
    .* | *@. | *@*..* | *..* | *@*@*) return 1 ;;
    esac

    return 0
}

# Prompt for confirmation (yes/no).
# Usage: _confirm [-p <prompt>] [-d <default>]
_confirm() {
    _prompt=""
    _default=""

    while getopts ':p:d:' _opt; do
        case "$_opt" in
        p) _prompt="$OPTARG" ;;
        d) _default="$OPTARG" ;;
        :)
            _error "_confirm: option requires an argument: '-$OPTARG'"
            return 2
            ;;
        ?)
            _error "_confirm: invalid option: '-$OPTARG'"
            return 2
            ;;
        esac
    done

    shift $((OPTIND - 1))

    if [ "$#" -ne 0 ]; then
        _error "_confirm: unexpected argument(s): $*"
        return 2
    fi

    if [ -z "$_default" ]; then
        _hint="[y/n]"
    else
        case "$_default" in
        y | Y | yes | Yes | YES) _hint="[Y/n]" ;;
        n | N | no | No | NO) _hint="[y/N]" ;;
        *)
            _error "_confirm: invalid argument: -d: expected y | Y | yes | Yes | YES | n | N | no | No | NO, got: '$_default'"
            return 2
            ;;
        esac
    fi

    while :; do
        printf "%s" "${_prompt:+$_prompt }$_hint: " >&2

        if ! read -r _confirmation; then
            return 1
        fi

        if [ -z "$_confirmation" ]; then
            _confirmation="$_default"
        fi

        case "$_confirmation" in
        y | Y | yes | Yes | YES) return 0 ;;
        n | N | no | No | NO) return 1 ;;
        *) printf "\033[31m%s\033[0m\n" "Please enter y/yes or n/no" >&2 ;;
        esac
    done
}

# Prompt for input.
# Usage: _input [-p <prompt>] [-h <hint>] [-d <default>] [-e <error>]
# Note: Requires command substitution to capture the output.
#       Providing -e makes the input required.
_input() {
    _prompt=""
    _hint=""
    _default=""
    _error=""

    while getopts ':p:h:d:e:' _opt; do
        case "$_opt" in
        p) _prompt="$OPTARG" ;;
        h) _hint="$OPTARG" ;;
        d) _default="$OPTARG" ;;
        e) _error="$OPTARG" ;;
        :)
            _error "_input: option requires an argument: '-$OPTARG'"
            return 2
            ;;
        ?)
            _error "_input: invalid option: '-$OPTARG'"
            return 2
            ;;
        esac
    done

    shift $((OPTIND - 1))

    if [ "$#" -ne 0 ]; then
        _error "_input: unexpected argument(s): $*"
        return 2
    fi

    while :; do
        printf '%s%s%s: ' "$_prompt" \
            "${_hint:+${_prompt:+ }($_hint)}" \
            "${_default:+${_hint:-${_prompt:+ }}[$_default]}" >&2

        if ! read -r _input; then
            return 1
        fi

        if [ -z "$_input" ]; then
            _input="$_default"
        fi

        if [ -n "$_error" ] && [ -z "$_input" ]; then
            printf "\033[31m%s\033[0m\n" "$_error" >&2
            continue
        fi

        printf "%s" "$_input"
        return 0
    done
}

# Prompt for a secret input (e.g., password).
# Usage: _secret [-p <prompt>] [-h <hint>] [-e <error>]
# Note: Requires command substitution to capture the output.
#       Providing -e makes the secret required.
_secret() {
    _prompt=""
    _hint=""
    _error=""

    while getopts ':p:h:e:' _opt; do
        case "$_opt" in
        p) _prompt="$OPTARG" ;;
        h) _hint="$OPTARG" ;;
        e) _error="$OPTARG" ;;
        :)
            _error "_secret: option requires an argument: '-$OPTARG'"
            return 2
            ;;
        ?)
            _error "_secret: invalid option: '-$OPTARG'"
            return 2
            ;;
        esac
    done

    shift $((OPTIND - 1))

    if [ "$#" -ne 0 ]; then
        _error "_secret: unexpected argument(s): $*"
        return 2
    fi

    while :; do
        printf '%s%s: ' "$_prompt" "${_hint:+${_prompt:+ }($_hint)}" >&2

        stty -echo 2>/dev/null

        if ! read -r _secret; then
            return 1
        fi

        stty echo 2>/dev/null
        printf "\n"

        if [ -n "$_error" ] && [ -z "$_secret" ]; then
            printf "\n\033[31m%s\033[0m\n" "$_error" >&2
            continue
        fi

        printf "%s" "$_secret"
        return 0
    done
}

# Prompt to select an option from a list.
# Usage: _select [-p <prompt>] [-e <error>] <option> [option2 ...]
# Note: Requires command substitution to capture the output.
#       Providing -e makes the select required.
_select() {
    _prompt=""
    _error=""

    while getopts ':p:e:' _opt; do
        case "$_opt" in
        p) _prompt="$OPTARG" ;;
        e) _error="$OPTARG" ;;
        :)
            _error "_select: option requires an argument: '-$OPTARG'"
            return 2
            ;;
        ?)
            _error "_select: invalid option: '-$OPTARG'"
            return 2
            ;;
        esac
    done

    shift $((OPTIND - 1))

    if [ "$#" -eq 0 ]; then
        _error "_select: expected at least 1 option, got: $#"
        return 2
    fi

    for _option in "$@"; do
        if [ -z "$_option" ]; then
            _error "_select: invalid argument: OPTION: expected non-empty string, got: '$_option'"
            return 2
        fi
    done

    while :; do
        printf "%s\n" "${_prompt:+$_prompt:}" >&2

        _i=1
        for _option in "$@"; do
            printf "%s\n" "$_i) $_option" >&2
            _i=$((_i + 1))
        done

        printf "%s" 'Choice: ' >&2

        if ! read -r _choice; then
            return 1
        fi

        if [ -z "$_choice" ]; then
            if [ -n "$_error" ]; then
                printf "\033[31m%s\033[0m\n\n" "$_error" >&2
                continue
            else
                return 0
            fi
        fi

        if ! _integer "$_choice" || [ "$_choice" -lt 1 ] || [ "$_choice" -gt "$((_i - 1))" ]; then
            printf "\033[31m%s\033[0m\n\n" "Invalid choice: $_choice" >&2
            continue
        fi

        _i=1
        for _option in "$@"; do
            if [ "$_i" -eq "$_choice" ]; then
                printf "%s" "$_option"
                return 0
            fi
            _i=$((_i + 1))
        done

    done
}

# Prompt to select multiple options from a list.
# Usage: _multiselect [-p <prompt>] [-e <error>] <option> [option2 ...]
# Note: Requires command substitution to capture the output.
#       Providing -e makes the multiselect required.
#       Uses § as internal delimiter — avoid using it in option.
_multiselect() {
    _prompt=""
    _error=""

    while getopts ':p:e:' _opt; do
        case "$_opt" in
        p) _prompt="$OPTARG" ;;
        e) _error="$OPTARG" ;;
        :)
            _error "_multiselect: option requires an argument: '-$OPTARG'"
            return 2
            ;;
        ?)
            _error "_multiselect: invalid option: '-$OPTARG'"
            return 2
            ;;
        esac
    done

    shift $((OPTIND - 1))

    if [ "$#" -eq 0 ]; then
        _error "_multiselect: expected at least 1 option, got: $#"
        return 2
    fi

    for _option in "$@"; do
        if [ -z "$_option" ]; then
            _error "_multiselect: invalid argument: OPTION: expected non-empty string, got: '$_option'"
            return 2
        fi
        if _str_contains "$_option" '§'; then
            _error "_multiselect: invalid argument: OPTION: contains reserved character: '§'"
            return 2
        fi
    done

    while :; do
        printf "%s\n" "${_prompt:+$_prompt:}" >&2

        _i=1
        for _option in "$@"; do
            printf "%s\n" "$_i) $_option" >&2
            _i=$((_i + 1))
        done

        printf "%s" 'Choices (comma or space separated): ' >&2

        if ! read -r _choices; then
            return 1
        fi

        if [ -z "$_choices" ]; then
            if [ -n "$_error" ]; then
                printf "\033[31m%s\033[0m\n\n" "$_error" >&2
                continue
            else
                return 0
            fi
        fi

        _choices=$(printf "%s" "$_choices" | tr ',' ' ' | tr -s ' ')

        _selected=""

        for _choice in $_choices; do
            if ! _integer "$_choice" || [ "$_choice" -lt 1 ] || [ "$_choice" -gt "$((_i - 1))" ]; then
                printf "\033[31m%s\033[0m\n\n" "Invalid choice: $_choice" >&2
                continue 2
            fi

            _i=1
            for _option in "$@"; do
                if [ "$_i" -eq "$_choice" ]; then
                    _selected="${_selected:+${_selected}§}$_option"
                fi
                _i=$((_i + 1))
            done
        done

        printf "%s" "$_selected"
        return 0
    done
}

# Check if the value is a valid git branch name.
# Usage: _git_branch <branch>
_git_branch() {
    _branch="$1"

    if [ "$#" -ne 1 ]; then
        _error "_git_branch: expected 1 argument, got: $#"
        return 2
    fi

    if _exists git; then
        git check-ref-format --branch "$_branch" >/dev/null 2>&1
        return
    fi

    [ "$_branch" = "@" ] && return 1

    case "$_branch" in
    [./-]* | *[./]) return 1 ;;
    *'.lock') return 1 ;;
    *'..'* | *'//'* | *'@{'*) return 1 ;;
    *' '* | *'~'* | *'^'* | *':'* | *'?'* | *'*'* | *'['* | *\\*) return 1 ;;
    esac

    _IFS="$IFS"
    IFS='/'
    for _segment in $_branch; do
        case "$_segment" in
        '.'* | *'.lock' | '')
            IFS="$_IFS"
            return 1
            ;;
        esac
    done
    IFS="$_IFS"

    return 0
}

# Check if path is a regular file.
# Usage: _file <path>
_file() {
    _path="$1"

    if [ "$#" -ne 1 ]; then
        _error "_file: expected 1 argument, got: $#"
        return 2
    fi

    [ -f "$_path" ]
}

# Check if path is a directory.
# Usage: _dir <path>
_dir() {
    _path="$1"

    if [ "$#" -ne 1 ]; then
        _error "_dir: expected 1 argument, got: $#"
        return 2
    fi

    [ -d "$_path" ]
}

# Check if path is readable.
# Usage: _readable <path>
_readable() {
    _path="$1"

    if [ "$#" -ne 1 ]; then
        _error "_readable: expected 1 argument, got: $#"
        return 2
    fi

    [ -r "$_path" ]
}

# Check if path is writable.
# Usage: _writable <path>
_writable() {
    _path="$1"

    if [ "$#" -ne 1 ]; then
        _error "_writable: expected 1 argument, got: $#"
        return 2
    fi

    [ -w "$_path" ]
}

# Check if path is executable.
# Usage: _executable <path>
_executable() {
    _path="$1"

    if [ "$#" -ne 1 ]; then
        _error "_executable: expected 1 argument, got: $#"
        return 2
    fi

    [ -x "$_path" ]
}

# Check if path is a symlink.
# Usage: _symlink <path>
_symlink() {
    _path="$1"

    if [ "$#" -ne 1 ]; then
        _error "_symlink: expected 1 argument, got: $#"
        return 2
    fi

    [ -L "$_path" ]
}

# Extract the filename from a path.
# Usage: _basename <path>
_basename() {
    _path="$1"

    if [ "$#" -ne 1 ]; then
        _error "_basename: expected 1 argument, got: $#"
        return 2
    fi

    basename "$_path"
}

# Extract filename without extension from a path.
# Usage: _filename <path>
_filename() {
    _path="$1"

    if [ "$#" -ne 1 ]; then
        _error "_filename: expected 1 argument, got: $#"
        return 2
    fi

    _basename=$(basename "$_path")
    printf "%s" "${_basename%.*}"
}

# Extract the file extension.
# Usage: _extension <path>
_extension() {
    _path="$1"

    if [ "$#" -ne 1 ]; then
        _error "_extension: expected 1 argument, got: $#"
        return 2
    fi

    printf '%s' "${_path##*.}"
}

# Extract the directory from a path.
# Usage: _dirname <path>
_dirname() {
    _path="$1"

    if [ "$#" -ne 1 ]; then
        _error "_dirname: expected 1 argument, got: $#"
        return 2
    fi

    dirname "$_path"
}

# Return the size of a path in bytes.
# Usage: _size <path>
_size() {
    _path="$1"

    if [ "$#" -ne 1 ]; then
        _error "_size: expected 1 argument, got: $#"
        return 2
    fi

    if [ ! -e "$_path" ]; then
        _error "_size: no such file or directory: $_path"
        return 1
    fi

    if [ ! -r "$_path" ]; then
        _error "_size: permission denied: $_path"
        return 1
    fi

    wc -c <"$_path" | tr -d ' '
}

# Ensure a file exists.
# Usage: _file_ensure <path>
_file_ensure() {
    _path="$1"

    if [ "$#" -ne 1 ]; then
        _error "_file_ensure: expected 1 argument, got: $#"
        return 2
    fi

    if ! mkdir -p "$(dirname "$_path")"; then
        _error "_file_ensure: permission denied: $(dirname "$_path")"
        return 1
    fi

    if [ ! -f "$_path" ]; then
        if ! touch "$_path"; then
            _error "_file_ensure: failed to create file: '$_path'"
            return 1
        fi
    fi
}

# Count the number of lines in a file.
# Usage: _file_lines <file>
_file_lines() {
    _file="$1"

    if [ "$#" -ne 1 ]; then
        _error "_file_lines: expected 1 argument, got: $#"
        return 2
    fi

    if [ ! -f "$_file" ]; then
        _error "_file_lines: not a file: $_file"
        return 1
    fi

    if [ ! -r "$_file" ]; then
        _error "_file_lines: permission denied: $_file"
        return 1
    fi

    wc -l <"$_file" | tr -d ' '
}

# Append a line to a file.
# Usage: _file_append <file> <line>
_file_append() {
    _file="$1"
    _line="$2"

    if [ "$#" -ne 2 ]; then
        _error "_file_append: expected 2 arguments, got: $#"
        return 2
    fi

    if [ -e "$_file" ] && [ ! -w "$_file" ]; then
        _error "_file_append: permission denied: $_file"
        return 1
    fi

    printf '%s\n' "$_line" >>"$_file"
}

# Check if a file contains a given substring.
# Usage: _file_contains <file> <substring>
_file_contains() {
    _file="$1"
    _substr="$2"

    if [ "$#" -ne 2 ]; then
        _error "_file_contains: expected 2 arguments, got: $#"
        return 2
    fi

    if [ ! -f "$_file" ]; then
        _error "_file_contains: not a file: '$_file'"
        return 1
    fi

    if [ ! -r "$_file" ]; then
        _error "_file_contains: permission denied: '$_file'"
        return 1
    fi

    grep -qF "$_substr" "$_file" 2>/dev/null
}

# Replace all occurrences of a pattern in a file.
# Usage: _file_replace <file> <search> <replace>
_file_replace() {
    _file="$1"
    _search="$2"
    _repl="$3"

    if [ "$#" -ne 3 ]; then
        _error "_file_replace: expected 3 arguments, got: $#"
        return 2
    fi

    if [ ! -f "$_file" ]; then
        _error "_file_replace: not a file: $_file"
        return 1
    fi

    if [ ! -w "$_file" ]; then
        _error "_file_replace: permission denied: $_file"
        return 1
    fi

    _search=$(_sed_escape "$_search")
    _repl=$(_sed_replace_escape "$_repl")

    sed -i "s|$_search|$_repl|g" "$_file" 2>/dev/null ||
        sed -i '' "s|$_search|$_repl|g" "$_file"
}

# Ensure a directory exists.
# Usage: _dir_ensure <path>
_dir_ensure() {
    _path="$1"

    if [ "$#" -ne 1 ]; then
        _error "_dir_ensure: expected 1 argument, got: $#"
        return 2
    fi

    if ! mkdir -p "$_path"; then
        _error "_dir_ensure: permission denied: $_path"
        return 1
    fi
}

# Join path components into a single path.
# Usage: _path_join <path> [path2 ...]
_path_join() {
    if [ "$#" -lt 1 ]; then
        _error "_path_join: expected at least 1 argument, got: $#"
        return 2
    fi

    _result=""
    _i=0

    for _part in "$@"; do
        if [ "$_i" -gt 0 ]; then
            _part="${_part#/}"
        fi

        _part="${_part%/}"

        if [ -z "$_part" ]; then
            _i=$((_i + 1))
            continue
        fi

        _result="${_result:+$_result/}${_part}"
        _i=$((_i + 1))
    done

    case "$1" in
    /*) _result="/${_result#/}" ;;
    esac

    printf '%s' "$_result"
}

# Resolve a path to its absolute form.
# Usage: _path_abs <path>
_path_abs() {
    _path="$1"

    if [ "$#" -ne 1 ]; then
        _error "_path_abs: expected 1 argument, got: $#"
        return 2
    fi

    if ! cd "$(dirname "$_path")" 2>/dev/null; then
        _error "_path_abs: no such file or directory: '$_path'"
        return 1
    fi

    printf '%s/%s' "$(pwd)" "$(basename "$_path")"
}

# Print the current operating system name.
# Usage: _sys_os
_sys_os() {
    if [ "$#" -ne 0 ]; then
        _error "_sys_os: expected 0 arguments, got: $#"
        return 2
    fi

    case "$(uname -s)" in
    Linux*) printf 'linux' ;;
    Darwin*) printf 'macos' ;;
    CYGWIN* | MINGW* | MSYS*) printf 'windows' ;;
    *) printf 'unknown' ;;
    esac
}

# Print the current system architecture.
# Usage: _sys_arch
_sys_arch() {
    if [ "$#" -ne 0 ]; then
        _error "_sys_arch: expected 0 arguments, got: $#"
        return 2
    fi

    case "$(uname -m)" in
    x86_64 | amd64) printf 'x86_64' ;;
    arm64 | aarch64) printf 'arm64' ;;
    armv7l) printf 'armv7' ;;
    *) printf 'unknown' ;;
    esac
}

# Extract the version number of a command.
# Usage: _version <command>
_version() {
    _cmd="$1"

    if [ "$#" -ne 1 ]; then
        _error "_version: expected 1 argument, got: $#"
        return 2
    fi

    if ! _exists "$_cmd"; then
        _error "_version: command not found: '$_cmd'"
        return 127
    fi

    {
        "$_cmd" --version 2>/dev/null ||
            "$_cmd" -version 2>/dev/null ||
            "$_cmd" -v 2>/dev/null
    } | grep -o '[0-9][0-9]*\.[0-9][0-9]*\(\.[0-9][0-9]*\)*' | head -1
}

# Print the PID of the current shell process.
# Usage: _pid
_pid() {
    if [ "$#" -ne 0 ]; then
        _error "_pid: expected 0 arguments, got: $#"
        return 2
    fi

    printf '%s' "$$"
}

# Create a temporary file and print its path.
# Usage: _tmpfile
_tmpfile() {
    if [ "$#" -ne 0 ]; then
        _error "_tmpfile: expected 0 arguments, got: $#"
        return 2
    fi

    mktemp "${TMPDIR:-/tmp}/sh_XXXXXX"
}

# Create a temporary directory and print its path.
# Usage: _tmpdir
_tmpdir() {
    if [ "$#" -ne 0 ]; then
        _error "_tmpdir: expected 0 arguments, got: $#"
        return 2
    fi

    mktemp -d "${TMPDIR:-/tmp}/sh_XXXXXX"
}

# Sleep for a duration with an optional message.
# Usage: _sleep <duration> [message]
_sleep() {
    _dur="$1"
    _msg="$2"

    if [ "$#" -lt 1 ]; then
        _error "_sleep: expected at least 1 argument, got: $#"
        return 2
    fi

    if [ "$#" -gt 2 ]; then
        _error "_sleep: expected at most 2 arguments, got: $#"
        return 2
    fi

    if ! _number "$_dur"; then
        _error "_sleep: invalid argument: DURATION: expected number, got: '$_dur'"
        return 2
    fi

    printf "\033[2m%s\033[0m${_msg:+\n}" "$_msg"

    sleep "$_dur"
}

# Check if network is online.
# Usage: _online [host]
_online() {
    _host="${1:-google.com}"

    if [ "$#" -gt 1 ]; then
        _error "_online: expected at most 1 argument, got: $#"
        return 2
    fi

    case "$(uname)" in
    Linux) ping -c 1 -W 2 "$_host" >/dev/null 2>&1 ;;
    Darwin | *BSD) ping -c 1 -t 2 "$_host" >/dev/null 2>&1 ;;
    MINGW* | MSYS* | CYGWIN*) ping -n 1 -w 2000 "$_host" >/dev/null 2>&1 ;;
    *) ping -c 1 "$_host" >/dev/null 2>&1 ;;
    esac
}

# Print the current timestamp in YYYY-MM-DD HH:MM:SS format.
# Usage: _timestamp
_timestamp() {
    if [ "$#" -ne 0 ]; then
        _error "_timestamp: expected 0 arguments, got: $#"
        return 2
    fi

    date '+%Y-%m-%d %H:%M:%S'
}

# Print the current date in YYYY-MM-DD format.
# Usage: _date
_date() {
    if [ "$#" -ne 0 ]; then
        _error "_date: expected 0 arguments, got: $#"
        return 2
    fi

    date '+%Y-%m-%d'
}

# Run a command with a spinner and message.
# Usage: _spinner [-m <message>] <command> [arg ...]
_spinner() {
    _msg=""

    while getopts ':m:' _opt; do
        case "$_opt" in
        m) _msg="$OPTARG" ;;
        :)
            _error "_spinner: option requires an argument: '-$OPTARG'"
            return 2
            ;;
        ?)
            _error "_spinner: invalid option: '-$OPTARG'"
            return 2
            ;;
        esac
    done

    shift $((OPTIND - 1))

    if [ "$#" -lt 1 ]; then
        _error "_spinner: expected 1 command, got: $#"
        return 2
    fi

    _cmd="$1"

    if ! _exists "$_cmd"; then
        _error "_spinner: command not found: '$_cmd'"
        return 127
    fi

    "$@" &
    _pid=$!

    _frames="|/-\\"

    _i=0
    while kill -0 "$_pid" 2>/dev/null; do
        _i=$(((_i + 1) % 4))
        _f=$(printf '%s' "$_frames" | cut -c$((_i + 1)))
        printf "\r%s %s" "$_f" "$_msg" >&2
        sleep 0.1
    done

    wait "$_pid"
    _result=$?

    printf '\r\033[2K' >&2

    return $_result
}

# Print a progress bar.
# Usage: _progress <current> <total> [width]
#       total=100 i=0
#       while [ "$i" -le "$total" ]; do
#           _progress "$i" "$total" "100"
#           i=$((i + 1))
#           sleep 1
#       done
_progress() {
    _current="$1"
    _total="$2"
    _width="${3:-40}"

    if [ "$#" -lt 2 ]; then
        _error "_progress: expected at least 2 arguments, got: $#"
        return 2
    fi

    if [ "$#" -gt 3 ]; then
        _error "_progress: expected at most 3 arguments, got: $#"
        return 2
    fi

    if ! _integer "$_current" || _negative "$_current"; then
        _error "_progress: invalid argument: CURRENT: expected non-negative integer, got: '$_current'"
        return 2
    fi

    if ! _integer "$_total" || ! _positive "$_total"; then
        _error "_progress: invalid argument: TOTAL: expected positive integer, got: '$_total'"
        return 2
    fi

    if ! _integer "$_width" || _negative "$_width"; then
        _error "_progress: invalid argument: WIDTH: expected non-negative integer, got: '$_width'"
        return 2
    fi

    [ "$_current" -gt "$_total" ] && _current="$_total"

    _percentage=$(awk "BEGIN { printf \"%d\", ($_current / $_total) * 100 }")
    _fill=$(awk "BEGIN { printf \"%d\", ($_current / $_total) * $_width }")
    _empty=$((_width - _fill))

    _bar=$(awk "BEGIN { for(i=0;i<$_fill;i++) printf \"#\" }")
    _space=$(awk "BEGIN { for(i=0;i<$_empty;i++) printf \"-\" }")

    printf "\r[%s%s] %d%%" "$_bar" "$_space" "$_percentage" >&2
}

# Compute the SHA-256 checksum of a file.
# Usage: _checksum <file>
_checksum() {
    _file="$1"

    if [ "$#" -ne 1 ]; then
        _error "_checksum: expected 1 argument, got: $#"
        return 2
    fi

    if [ ! -f "$_file" ]; then
        _error "_checksum: not a file: '$_file'"
        return 1
    fi

    if [ ! -r "$_file" ]; then
        _error "_checksum: permission denied: '$_file'"
        return 1
    fi

    if _exists sha256sum; then
        sha256sum "$_file" | cut -d' ' -f1
    elif _exists shasum; then
        shasum -a 256 "$_file" | cut -d' ' -f1
    else
        _error "_checksum: no checksum command found (sha256sum, shasum)"
        return 127
    fi
}
