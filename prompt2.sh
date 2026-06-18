#!/bin/sh

# =============================================================================
# prompt.sh — Laravel-style POSIX sh prompts
# =============================================================================
# All prompts use environment variables for input:
#   PROMPT_QUESTION  — the question to display (required)
#   PROMPT_HINT      — hint/placeholder shown dimmed in box (optional)
#   PROMPT_REQUIRED  — "yes" to disallow empty input (optional)
#   PROMPT_DEFAULT   — default value if user presses enter (optional)
#   PROMPT_OPTIONS   — pipe-delimited list for select/multiselect (optional)
#   PROMPT_VALIDATE  — shell function name for custom validation (optional)
# Result stored in $prompt_result

# --- Colors ---
_PC_BOX='\033[32m'
_PC_DANGER='\033[31m'
_PC_QUESTION='\033[34m'
_PC_DIM='\033[2m'
_PC_BOLD='\033[1m'
_PC_CYAN='\033[36m'
_PC_YELLOW='\033[33m'
_PC_RESET='\033[0m'

# --- Terminal width ---
_prompt_width() {
    _pw_term=$(stty size </dev/tty 2>/dev/null | cut -d' ' -f2)
    _pw_term="${_pw_term:-80}"
    _pw_max=$((_pw_term < 80 ? _pw_term : 80))
    _pw_q=${#PROMPT_QUESTION}
    _pw_h=${#PROMPT_HINT}
    _pw_min=$((_pw_q > _pw_h ? _pw_q : _pw_h))
    _pw_min=$((_pw_min + 4))
    _pw_w=$((_pw_max > _pw_min ? _pw_max : _pw_min))
    [ "$_pw_w" -lt 40 ] && _pw_w=40
    printf '%s' "$_pw_w"
    unset _pw_term _pw_max _pw_q _pw_h _pw_min _pw_w
}

# --- Draw top border with question ---
_prompt_top() {
    _pt_color="${1:-$_PC_BOX}"
    _pt_w="$2"
    _pt_pad_len=$((_pt_w - ${#PROMPT_QUESTION} - 4))
    [ "$_pt_pad_len" -lt 1 ] && _pt_pad_len=1
    _pt_pad=$(printf '─%.0s' $(seq 1 "$_pt_pad_len"))
    printf "${_pt_color}┌${_PC_RESET} ${_PC_QUESTION}${_PC_BOLD}%s${_PC_RESET} ${_pt_color}%s┐${_PC_RESET}\n" \
        "$PROMPT_QUESTION" "$_pt_pad"
    unset _pt_color _pt_w _pt_pad_len _pt_pad
}

# --- Draw hint/content line ---
_prompt_mid() {
    _pm_color="${1:-$_PC_BOX}"
    _pm_w="$2"
    _pm_text="${3:-}"
    _pm_space_len=$((_pm_w - ${#_pm_text} - 4))
    [ "$_pm_space_len" -lt 0 ] && _pm_space_len=0
    _pm_space=$(printf ' %.0s' $(seq 1 "$_pm_space_len"))
    printf "${_pm_color}│${_PC_RESET} ${_PC_DIM}%s%s${_PC_RESET} ${_pm_color}│${_PC_RESET}\n" \
        "$_pm_text" "$_pm_space"
    unset _pm_color _pm_w _pm_text _pm_space_len _pm_space
}

# --- Draw empty middle line ---
_prompt_mid_empty() {
    _pe_color="${1:-$_PC_BOX}"
    _pe_w="$2"
    _pe_inner=$(printf ' %.0s' $(seq 1 $((_pe_w - 2))))
    printf "${_pe_color}│${_PC_RESET}%s${_pe_color}│${_PC_RESET}\n" "$_pe_inner"
    unset _pe_color _pe_w _pe_inner
}

# --- Draw bottom border ---
_prompt_bottom() {
    _pb_color="${1:-$_PC_BOX}"
    _pb_w="$2"
    _pb_line=$(printf '─%.0s' $(seq 1 $((_pb_w - 2))))
    printf "${_pb_color}└%s┘${_PC_RESET}\n" "$_pb_line"
    unset _pb_color _pb_w _pb_line
}

# --- Draw error line ---
_prompt_error() {
    printf "${_PC_DANGER}  ✘ %s${_PC_RESET}\n" "$1" >&2
}

# --- Draw success/info line ---
_prompt_info() {
    printf "${_PC_DIM}  %s${_PC_RESET}\n" "$1"
}

# --- Handle Ctrl+C ---
_prompt_cancel() {
    _pcancel_w="$1"
    printf "\r\033[2K\033[1A"
    _prompt_top "$_PC_DANGER" "$_pcancel_w"
    _prompt_mid_empty "$_PC_DANGER" "$_pcancel_w"
    _prompt_bottom "$_PC_DANGER" "$_pcancel_w"
    printf "${_PC_DANGER}  Cancelled.${_PC_RESET}\n"
    exit 1
}

# =============================================================================
# _prompt_input — free text input
# =============================================================================
_prompt_input() {
    _pi_w=$(_prompt_width)
    trap "_prompt_cancel $_pi_w" INT
    while true; do
        _prompt_top "$_PC_BOX" "$_pi_w"
        if [ -n "${PROMPT_HINT:-}" ]; then
            _prompt_mid "$_PC_BOX" "$_pi_w" "$PROMPT_HINT"
        else
            _prompt_mid_empty "$_PC_BOX" "$_pi_w"
        fi
        _prompt_bottom "$_PC_BOX" "$_pi_w"
        printf "\033[2A\033[3G"
        read -r prompt_result </dev/tty || _prompt_cancel "$_pi_w"
        printf "\033[2B\n"
        # Apply default
        [ -z "$prompt_result" ] && [ -n "${PROMPT_DEFAULT:-}" ] && prompt_result="$PROMPT_DEFAULT"
        # Required check
        if [ -z "$prompt_result" ] && [ "${PROMPT_REQUIRED:-}" = "yes" ]; then
            _prompt_error "This field is required."
            continue
        fi
        # Custom validation
        if [ -n "${PROMPT_VALIDATE:-}" ] && [ -n "$prompt_result" ]; then
            _pv_err=$("$PROMPT_VALIDATE" "$prompt_result" 2>&1)
            if [ $? -ne 0 ]; then
                _prompt_error "${_pv_err:-Invalid value.}"
                continue
            fi
        fi
        break
    done
    trap - INT
    unset _pi_w _pv_err
}

# =============================================================================
# _prompt_secret — hidden input (password)
# =============================================================================
_prompt_secret() {
    _ps_w=$(_prompt_width)
    trap "_prompt_cancel $_ps_w" INT
    while true; do
        _prompt_top "$_PC_BOX" "$_ps_w"
        _prompt_mid "$_PC_BOX" "$_ps_w" "${PROMPT_HINT:-••••••••}"
        _prompt_bottom "$_PC_BOX" "$_ps_w"
        printf "\033[2A\033[3G"
        # Disable echo for secret input
        stty -echo 2>/dev/null
        read -r prompt_result </dev/tty
        stty echo 2>/dev/null
        printf "\033[2B\n"
        if [ -z "$prompt_result" ] && [ "${PROMPT_REQUIRED:-}" = "yes" ]; then
            _prompt_error "This field is required."
            continue
        fi
        break
    done
    trap - INT
    unset _ps_w
}

# =============================================================================
# _prompt_confirm — yes/no confirmation
# =============================================================================
_prompt_confirm() {
    _pc_w=$(_prompt_width)
    _pc_default="${PROMPT_DEFAULT:-no}"
    if [ "$_pc_default" = "yes" ]; then
        _pc_hint="[Y/n]"
    else
        _pc_hint="[y/N]"
    fi
    trap "_prompt_cancel $_pc_w" INT
    while true; do
        _prompt_top "$_PC_BOX" "$_pc_w"
        _prompt_mid "$_PC_BOX" "$_pc_w" "$_pc_hint"
        _prompt_bottom "$_PC_BOX" "$_pc_w"
        printf "\033[2A\033[3G"
        read -r _pc_ans </dev/tty || _prompt_cancel "$_pc_w"
        printf "\033[2B\n"
        [ -z "$_pc_ans" ] && _pc_ans="$_pc_default"
        case "$_pc_ans" in
            [yY]|[yY][eE][sS]) prompt_result="yes"; break ;;
            [nN]|[nN][oO])     prompt_result="no";  break ;;
            *) _prompt_error "Please enter y or n." ;;
        esac
    done
    trap - INT
    unset _pc_w _pc_default _pc_hint _pc_ans
}

# =============================================================================
# _prompt_number — numeric input only
# =============================================================================
_prompt_number() {
    _pn_w=$(_prompt_width)
    _pn_hint="${PROMPT_HINT:-Enter a number}"
    trap "_prompt_cancel $_pn_w" INT
    while true; do
        _prompt_top "$_PC_BOX" "$_pn_w"
        _prompt_mid "$_PC_BOX" "$_pn_w" "$_pn_hint"
        _prompt_bottom "$_PC_BOX" "$_pn_w"
        printf "\033[2A\033[3G"
        read -r prompt_result </dev/tty || _prompt_cancel "$_pn_w"
        printf "\033[2B\n"
        [ -z "$prompt_result" ] && [ -n "${PROMPT_DEFAULT:-}" ] && prompt_result="$PROMPT_DEFAULT"
        if [ -z "$prompt_result" ] && [ "${PROMPT_REQUIRED:-}" = "yes" ]; then
            _prompt_error "This field is required."
            continue
        fi
        if [ -n "$prompt_result" ]; then
            case "$prompt_result" in
                ''|*[!0-9.-]*) _prompt_error "Please enter a valid number."; continue ;;
            esac
        fi
        break
    done
    trap - INT
    unset _pn_w _pn_hint
}

# =============================================================================
# _prompt_select — single choice from list
# Uses arrow key-style navigation via numbered menu
# =============================================================================
_prompt_select() {
    _psel_w=$(_prompt_width)
    # Parse pipe-delimited options
    _psel_IFS="$IFS"; IFS='|'
    set -- ${PROMPT_OPTIONS:-}
    IFS="$_psel_IFS"
    _psel_count=$#
    _psel_selected=1

    if [ "$_psel_count" -eq 0 ]; then
        _prompt_error "No options provided in PROMPT_OPTIONS"
        return 1
    fi

    trap "_prompt_cancel $_psel_w" INT

    while true; do
        _prompt_top "$_PC_BOX" "$_psel_w"

        # Print each option
        _psel_i=1
        for _psel_opt in "$@"; do
            if [ "$_psel_i" -eq "$_psel_selected" ]; then
                _psel_marker="${_PC_CYAN}❯ ${_PC_RESET}${_PC_BOLD}"
                _psel_end="${_PC_RESET}"
            else
                _psel_marker="  ${_PC_DIM}"
                _psel_end="${_PC_RESET}"
            fi
            _psel_line="${_psel_marker}${_psel_opt}${_psel_end}"
            _psel_space_len=$((_psel_w - ${#_psel_opt} - 4))
            [ "$_psel_space_len" -lt 0 ] && _psel_space_len=0
            _psel_space=$(printf ' %.0s' $(seq 1 "$_psel_space_len"))
            printf "${_PC_BOX}│${_PC_RESET} %s%s ${_PC_BOX}│${_PC_RESET}\n" \
                "$_psel_line" "$_psel_space"
            _psel_i=$((_psel_i + 1))
        done

        _prompt_bottom "$_PC_BOX" "$_psel_w"
        _prompt_info "↑/↓ to navigate, enter to select, or type number (1-${_psel_count})"

        # Move cursor up to input area
        _psel_lines=$((_psel_count + 2))
        printf "\033[${_psel_lines}A\r"

        read -r _psel_key </dev/tty || _prompt_cancel "$_psel_w"

        # Move cursor back down
        printf "\033[${_psel_lines}B"
        # Clear options + info line
        _psel_clear=$((_psel_count + 2))
        printf "\033[${_psel_clear}A"
        _psel_ci=0
        while [ "$_psel_ci" -le "$_psel_clear" ]; do
            printf "\033[2K\n"
            _psel_ci=$((_psel_ci + 1))
        done
        printf "\033[${_psel_clear}A\033[1A"

        case "$_psel_key" in
            # Up arrow (ESC [ A) — simplified: treat 'k' as up too
            k|K) _psel_selected=$((_psel_selected - 1))
                 [ "$_psel_selected" -lt 1 ] && _psel_selected="$_psel_count" ;;
            # Down arrow — treat 'j' as down
            j|J) _psel_selected=$((_psel_selected + 1))
                 [ "$_psel_selected" -gt "$_psel_count" ] && _psel_selected=1 ;;
            # Number
            [0-9]*)
                if [ "$_psel_key" -ge 1 ] && [ "$_psel_key" -le "$_psel_count" ] 2>/dev/null; then
                    _psel_selected="$_psel_key"
                    # Get value at selected index
                    _psel_vi=1
                    for _psel_v in "$@"; do
                        [ "$_psel_vi" -eq "$_psel_selected" ] && { prompt_result="$_psel_v"; break; }
                        _psel_vi=$((_psel_vi + 1))
                    done
                    break
                fi
                ;;
            # Enter — confirm current selection
            "")
                _psel_vi=1
                for _psel_v in "$@"; do
                    [ "$_psel_vi" -eq "$_psel_selected" ] && { prompt_result="$_psel_v"; break; }
                    _psel_vi=$((_psel_vi + 1))
                done
                break
                ;;
        esac
    done

    trap - INT
    unset _psel_w _psel_IFS _psel_count _psel_selected _psel_i _psel_opt
    unset _psel_marker _psel_end _psel_line _psel_space_len _psel_space
    unset _psel_lines _psel_clear _psel_ci _psel_key _psel_vi _psel_v
}

# =============================================================================
# _prompt_multiselect — multiple choices from list
# =============================================================================
_prompt_multiselect() {
    _pms_w=$(_prompt_width)
    _pms_IFS="$IFS"; IFS='|'
    set -- ${PROMPT_OPTIONS:-}
    IFS="$_pms_IFS"
    _pms_count=$#
    _pms_cursor=1
    # Track selected as pipe-delimited indices e.g. "1|3"
    _pms_checked=""

    [ "$_pms_count" -eq 0 ] && { _prompt_error "No options provided."; return 1; }

    trap "_prompt_cancel $_pms_w" INT

    while true; do
        _prompt_top "$_PC_BOX" "$_pms_w"

        _pms_i=1
        for _pms_opt in "$@"; do
            # Check if this index is selected
            _pms_is_checked=0
            _pms_cIFS="$IFS"; IFS='|'
            for _pms_ci in $_pms_checked; do
                [ "$_pms_ci" -eq "$_pms_i" ] && _pms_is_checked=1 && break
            done
            IFS="$_pms_cIFS"

            if [ "$_pms_is_checked" -eq 1 ]; then
                _pms_box="${_PC_CYAN}◼${_PC_RESET}"
            else
                _pms_box="${_PC_DIM}◻${_PC_RESET}"
            fi

            if [ "$_pms_i" -eq "$_pms_cursor" ]; then
                _pms_arrow="${_PC_CYAN}❯${_PC_RESET} "
                _pms_label="${_PC_BOLD}${_pms_opt}${_PC_RESET}"
            else
                _pms_arrow="  "
                _pms_label="${_PC_DIM}${_pms_opt}${_PC_RESET}"
            fi

            _pms_space_len=$((_pms_w - ${#_pms_opt} - 8))
            [ "$_pms_space_len" -lt 0 ] && _pms_space_len=0
            _pms_space=$(printf ' %.0s' $(seq 1 "$_pms_space_len"))
            printf "${_PC_BOX}│${_PC_RESET} %s%s %s%s ${_PC_BOX}│${_PC_RESET}\n" \
                "$_pms_arrow" "$_pms_box" "$_pms_label" "$_pms_space"
            _pms_i=$((_pms_i + 1))
        done

        _prompt_bottom "$_PC_BOX" "$_pms_w"
        _prompt_info "↑/↓ navigate, space to toggle, enter to confirm"

        _pms_lines=$((_pms_count + 2))
        printf "\033[${_pms_lines}A\r"
        read -r _pms_key </dev/tty || _prompt_cancel "$_pms_w"
        printf "\033[${_pms_lines}B"

        _pms_clear=$((_pms_count + 2))
        printf "\033[${_pms_clear}A"
        _pms_cli=0
        while [ "$_pms_cli" -le "$_pms_clear" ]; do
            printf "\033[2K\n"
            _pms_cli=$((_pms_cli + 1))
        done
        printf "\033[${_pms_clear}A\033[1A"

        case "$_pms_key" in
            k|K) _pms_cursor=$((_pms_cursor - 1))
                 [ "$_pms_cursor" -lt 1 ] && _pms_cursor="$_pms_count" ;;
            j|J) _pms_cursor=$((_pms_cursor + 1))
                 [ "$_pms_cursor" -gt "$_pms_count" ] && _pms_cursor=1 ;;
            " ")
                # Toggle current item
                _pms_found=0
                _pms_new=""
                _pms_tIFS="$IFS"; IFS='|'
                for _pms_ti in $_pms_checked; do
                    if [ "$_pms_ti" -eq "$_pms_cursor" ]; then
                        _pms_found=1
                    else
                        if [ -z "$_pms_new" ]; then _pms_new="$_pms_ti"
                        else _pms_new="${_pms_new}|${_pms_ti}"
                        fi
                    fi
                done
                IFS="$_pms_tIFS"
                if [ "$_pms_found" -eq 0 ]; then
                    if [ -z "$_pms_checked" ]; then _pms_checked="$_pms_cursor"
                    else _pms_checked="${_pms_checked}|${_pms_cursor}"
                    fi
                else
                    _pms_checked="$_pms_new"
                fi
                ;;
            "")
                # Build result from checked indices
                prompt_result=""
                _pms_rIFS="$IFS"; IFS='|'
                for _pms_ri in $_pms_checked; do
                    _pms_rvi=1
                    for _pms_rv in "$@"; do
                        if [ "$_pms_rvi" -eq "$_pms_ri" ]; then
                            if [ -z "$prompt_result" ]; then prompt_result="$_pms_rv"
                            else prompt_result="${prompt_result}|${_pms_rv}"
                            fi
                            break
                        fi
                        _pms_rvi=$((_pms_rvi + 1))
                    done
                done
                IFS="$_pms_rIFS"
                break
                ;;
        esac
    done

    trap - INT
    unset _pms_w _pms_IFS _pms_count _pms_cursor _pms_checked _pms_i _pms_opt
    unset _pms_is_checked _pms_cIFS _pms_ci _pms_box _pms_arrow _pms_label
    unset _pms_space_len _pms_space _pms_lines _pms_clear _pms_cli _pms_key
    unset _pms_found _pms_new _pms_tIFS _pms_ti _pms_rIFS _pms_ri _pms_rvi _pms_rv
}

