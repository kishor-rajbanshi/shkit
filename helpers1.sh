# shellcheck shell=sh

# Fetch a resource.
# Usage: _fetch <url> [output]
# _fetch() {
#     _c=""
#     _w=""
#     _url="$1"
#     _output="$2"

#     while getopts ':c:w:' _opt; do
#         case "$_opt" in
#         c) _c="$OPTARG" ;;
#         w) _w="$OPTARG" ;;
#         :)
#             _error "_fetch: option requires an argument: '-$OPTARG'"
#             return 2
#             ;;
#         ?)
#             _error "_fetch: invalid option: '-$OPTARG'"
#             return 2
#             ;;
#         esac
#     done

#     shift $((OPTIND - 1))

#     if [ "$#" -lt 1 ]; then
#         _error "_fetch: expected at least 1 argument: got '$#'"
#         return 2
#     fi

#     if [ "$#" -gt 2 ]; then
#         _error "_fetch: expected at most 2 arguments: got '$#'"
#         return 2
#     fi

#     if _exists curl; then
#         curl -fsSL "$_url" ${_output:+-o "$_output"}
#     elif _exists wget; then
#         wget -q "$_url" ${_output:+-O "$_output"}
#     else
#         _error "_fetch: no download tool found: install curl or wget"
#         return 127
#     fi
# }

# -----------------------------------------------------------------------------
# ARRAY (pipe-delimited strings — default delimiter: |)
# Avoid using | in values. Pass custom delimiter as last arg if needed.
# -----------------------------------------------------------------------------

_arr_push() {
    # _arr_push "list" "item" [delimiter]
    _ap_d="${3:-|}"
    if [ -z "$1" ]; then
        printf '%s' "$2"
    else
        printf '%s%s%s' "$1" "$_ap_d" "$2"
    fi
    unset _ap_d
}

_arr_contains() {
    # _arr_contains "list" "item" [delimiter]
    _ac_d="${3:-|}"
    _ac_IFS="$IFS"
    IFS="$_ac_d"
    for _ac_i in $1; do
        if [ "$_ac_i" = "$2" ]; then
            IFS="$_ac_IFS"
            unset _ac_d _ac_IFS _ac_i
            return 0
        fi
    done
    IFS="$_ac_IFS"
    unset _ac_d _ac_IFS _ac_i
    return 1
}

_arr_length() {
    # _arr_length "list" [delimiter]
    [ -z "$1" ] && printf '0' && return
    _al_d="${2:-|}"
    printf '%s' "$1" | tr "$_al_d" '\n' | grep -c '.' | tr -d ' '
    unset _al_d
}

_arr_join() {
    # _arr_join "list" "new_delimiter" [old_delimiter]
    _aj_old="${3:-|}"
    _aj_result=""
    _aj_IFS="$IFS"
    IFS="$_aj_old"
    for _aj_i in $1; do
        if [ -z "$_aj_result" ]; then
            _aj_result="$_aj_i"
        else
            _aj_result="${_aj_result}${2}${_aj_i}"
        fi
    done
    IFS="$_aj_IFS"
    printf '%s' "$_aj_result"
    unset _aj_old _aj_result _aj_IFS _aj_i
}

_arr_first() {
    printf '%s' "$1" | cut -d"${2:-|}" -f1
}

_arr_last() {
    printf '%s' "$1" | rev | cut -d"${2:-|}" -f1 | rev
}

_arr_nth() {
    # _arr_nth "list" n [delimiter]
    printf '%s' "$1" | cut -d"${3:-|}" -f"$2"
}

_arr_remove() {
    # _arr_remove "list" "item" [delimiter]
    _ar_d="${3:-|}"
    _ar_result=""
    _ar_IFS="$IFS"
    IFS="$_ar_d"
    for _ar_i in $1; do
        if [ "$_ar_i" != "$2" ]; then
            _ar_result="$(_arr_push "$_ar_result" "$_ar_i" "$_ar_d")"
        fi
    done
    IFS="$_ar_IFS"
    printf '%s' "$_ar_result"
    unset _ar_d _ar_result _ar_IFS _ar_i
}

# -----------------------------------------------------------------------------
# PROCESS & SIGNAL
# -----------------------------------------------------------------------------

_retry() {
    # _retry attempts delay command [args...]
    _rt_tries="$1"
    _rt_delay="$2"
    shift 2
    _rt_n=0
    while [ "$_rt_n" -lt "$_rt_tries" ]; do
        "$@" && return 0
        _rt_n=$((_rt_n + 1))
        [ "$_rt_n" -lt "$_rt_tries" ] && {
            _print_warning "Attempt $_rt_n/$_rt_tries failed — retrying in ${_rt_delay}s..."
            sleep "$_rt_delay"
        }
    done
    _print_error "Failed after $_rt_tries attempts: $*"
    unset _rt_tries _rt_delay _rt_n
    return 1
}

_timeout() {
    # _timeout seconds command [args...]
    _to_secs="$1"
    shift
    "$@" &
    _to_pid=$!
    (
        sleep "$_to_secs"
        kill "$_to_pid" 2>/dev/null
    ) &
    _to_watch=$!
    wait "$_to_pid" 2>/dev/null
    _to_ret=$?
    kill "$_to_watch" 2>/dev/null
    wait "$_to_watch" 2>/dev/null
    unset _to_secs _to_pid _to_watch
    return $_to_ret
}

_run() {
    "$@" || _die "Command failed: $*"
}

_run_quiet() {
    "$@" >/dev/null 2>&1 || _die "Command failed: $*"
}

# -----------------------------------------------------------------------------
# ENV & CONFIG
# -----------------------------------------------------------------------------

_env_require() {
    for _er_var in "$@"; do
        eval "_er_val=\${${_er_var}:-}"
        [ -n "$_er_val" ] || _die "Required environment variable not set: $_er_var"
    done
    unset _er_var _er_val
}

_env_default() {
    # _env_default VAR "default"
    eval "_ed_val=\${$1:-}"
    [ -z "$_ed_val" ] && eval "$1=\"\$2\""
    unset _ed_val
}

_dotenv_load() {
    _de_file="${1:-.env}"
    [ -f "$_de_file" ] || {
        _print_warning ".env not found: $_de_file"
        return 1
    }
    while IFS='=' read -r _de_key _de_val; do
        case "$_de_key" in '' | \#*) continue ;; esac
        _de_key=$(_str_trim "$_de_key")
        _de_val=$(_str_trim "$_de_val")
        _de_val="${_de_val%\"}"
        _de_val="${_de_val#\"}"
        _de_val="${_de_val%\'}"
        _de_val="${_de_val#\'}"
        export "$_de_key=$_de_val"
    done <"$_de_file"
    unset _de_file _de_key _de_val
}

# -----------------------------------------------------------------------------
# GIT
# -----------------------------------------------------------------------------

_git_branch() { git rev-parse --abbrev-ref HEAD 2>/dev/null; }
_git_root() { git rev-parse --show-toplevel 2>/dev/null; }
_git_last_commit() { git log -1 --format="%H" 2>/dev/null; }
_git_last_tag() { git describe --tags --abbrev=0 2>/dev/null; }
_git_is_repo() { git rev-parse --git-dir >/dev/null 2>&1; }

_git_is_clean() {
    [ -z "$(git status --porcelain 2>/dev/null)" ]
}

_git_has_remote() {
    git remote get-url "${1:-origin}" >/dev/null 2>&1
}

# -----------------------------------------------------------------------------
# MISC
# -----------------------------------------------------------------------------
