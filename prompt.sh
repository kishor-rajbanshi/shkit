#!/usr/bin/env sh
# shellcheck disable=all
# ----------------------------------------------------
# Author:          Kishor Rajbanshi
# Website:         https://kishor-rajbanshi.com.np
# License:         MIT
# ----------------------------------------------------

set -eu

_GIST_URL="https://gist.githubusercontent.com/kishor-rajbanshi/e15bcab9a1a8fc95a04047f07e5b5b3f/raw"

_helpers=$(mktemp)

# shellcheck source=/dev/null
curl -fsSL "$_GIST_URL/helpers.sh?$(date +%s)" -o "$_helpers" && . "$_helpers" &&
    . ./helpers.sh

# shellcheck disable=SC2078
if [ _interactive_terminal ]; then
    _die "$(_color red)Error: This script must be run in a terminal.$(_color reset)" >&2
fi

echo "${_RED}Error: This script must be run in a terminal.${_RESET}"

#
#
#
#
#
#
#
#
#
exit 1

# --- Colors ---
CLR_BOX='\033[32m'
CLR_DANGER='\033[31m'
CLR_RESET='\033[0m'
CLR_QUESTION='\033[34m'

# --- Parameters ---
_question="${1:-Input}"
_hint="${2:-}"
_required="${3:-required}"

# --- Terminal width ---
_term_width=$(tput cols 2>/dev/null)
_term_width=${_term_width:-80}

# --- Box width: fit to terminal, min 40, max 80 ---
# question + 4 chars overhead (┌  space + space ┐) minimum
_min_width=$((_term_width < 80 ? _term_width : 80))
_q_min=$((${#_question} + 4))
_h_min=$((${#_hint} + 4))
_content_min=$((_q_min > _h_min ? _q_min : _h_min))
_width=$((_min_width > _content_min ? _min_width : _content_min))
[ "$_width" -lt 40 ] && _width=40

_hline=$(printf '─%.0s' $(seq 1 $((_width - 2))))

# --- Draw box ---
_draw_box() {
    _clr="$1"

    # Top border: ┌ question ───┐
    # Remaining space after "┌ " + question + " " + "┐"
    _q_pad_len=$((_width - ${#_question} - 4))
    if [ "$_q_pad_len" -lt 1 ]; then _q_pad_len=1; fi
    _q_pad=$(printf '─%.0s' $(seq 1 "$_q_pad_len"))
    printf "${_clr}┌${CLR_RESET} ${CLR_QUESTION}%s${CLR_RESET} ${_clr}%s┐${CLR_RESET}\n" "$_question" "$_q_pad"

    # Hint line: │ hint   │ (only if hint provided)
    if [ -n "$_hint" ]; then
        _h_space_len=$((_width - ${#_hint} - 4))
        if [ "$_h_space_len" -lt 0 ]; then _h_space_len=0; fi
        _h_space=$(printf ' %.0s' $(seq 1 "$_h_space_len"))
        printf "${_clr}│${CLR_RESET} \033[2m%s%s\033[0m ${_clr}│${CLR_RESET}\n" "$_hint" "$_h_space"
    else
        # Empty middle line if no hint
        _inner=$(printf ' %.0s' $(seq 1 $((_width - 2))))
        printf "${_clr}│${CLR_RESET}%s${_clr}│${CLR_RESET}\n" "$_inner"
    fi

    # Bottom border
    printf "${_clr}└%s┘${CLR_RESET}\n" "$_hline"
}

# --- Handle Ctrl+C ---
_handle_cancel() {
    printf "\r\033[2K\033[1A"
    _draw_box "$CLR_DANGER"
    printf "${CLR_DANGER}  Cancelled.${CLR_RESET}\n"
    exit 1
}
trap _handle_cancel INT

# --- Prompt loop ---
while true; do
    _draw_box "$CLR_BOX"
    printf "\033[2A\033[3G"
    read -r prompt_result </dev/tty || _handle_cancel
    printf "\033[2B\n"

    if [ -z "$prompt_result" ] && [ "$_required" = "required" ]; then
        printf "${CLR_DANGER}  Input cannot be empty.${CLR_RESET}\n" >&2
        continue
    fi
    break
done

trap - INT

# --- Cleanup ---
unset _question _hint _required _term_width _min_width _q_min _h_min _content_min
unset _width _hline _q_pad_len _q_pad _h_space_len _h_space _inner _clr

# _prompt_secret() {
#     _question="$1"
#     _hint="$2"
#     _required="${3:-required}"

#     if [ -z "$1" ] || [ -z "$2" ]; then
#         _usage "_prompt_secret question hint [required|optional]"
#         return 1
#     fi
# }

_prompt_input() {
    _question="$1"
    _hint="$2"
    _required="${3:-required}"

    if [ -z "$1" ] || [ -z "$2" ]; then
        _usage "_prompt_input question hint [required|optional]"
        return 1
    fi

    _required stty cut

    _terminal_width=$(stty size </dev/tty 2>/dev/null | cut -d' ' -f2)

    _min_width=$((_terminal_width < 50 ? _terminal_width : 50))

    # _box_width=$((_terminal_width < 80 ? _terminal_width : 80))
}
