# vim:ft=zsh
#
# hydrogen zsh theme
# https://github.com/xylous/hydrogen
#
# Code licensed under the MIT License
#   https://raw.githubusercontent.com/xylous/hydrogen/master/LICENSE
#
# @author xylous <xylous.e@gmail.com>
# @maintainer xylous <xylous.e@gmail.com>

function hydrogen_theme() {
    setopt PROMPT_SUBST
    set_colours

    PROMPT='$(fill_line "$(top_right_part)" "$(gitstatus)      ")'
    PROMPT+=$'\n'
    PROMPT+='└ '

    # If the last exit code is > 0, the integer between brackets will be coloured
    # red, otherwise green (indicating success)
    RPROMPT="[%(?.${FG_GREEN}%?${FG_CLR}.${FG_RED}%?${FG_CLR})]"

    search_history_with_text_already_inputted
    set_tab_completion_menu_bindings
    set_key_bindings

    # Use LS_COLORS when completing filenames
    zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
}

function set_colours() {
    # FG = ForeGround
    export FG_CLR='%F{default}'

    if [[ $(tput colors) -ge 256 ]]; then
        export FG_USERNAME='%F{167}'
        export FG_HOSTNAME='%F{67}'
        export FG_PATH="%F{43}"
        export FG_GREEN='%F{34}'
        export FG_RED='%F{9}'
    else
        export FG_USERNAME='%F{red}'
        export FG_HOSTNAME='%F{blue}'
        export FG_PATH="%F{cyan}"
        export FG_GREEN='%F{green}'
        export FG_RED='%F{red}'
    fi
}

function top_right_part()
{
    # Username and hostname
    SECTION_A="(${FG_USERNAME}%n${FG_CLR}@${FG_HOSTNAME}%m${FG_CLR})"
    # Path
    SECTION_B="${FG_PATH}%~${FG_CLR}"

    echo "┌─${SECTION_A} | ${SECTION_B}"
}

###
# Usage: fill_line LEFT RIGHT
# Sets REPLY to LEFT<spaces>RIGHT with enough spaces in the middle to fill a
# terminal line.
###
function fill_line() {
    emulate -L zsh
    prompt_length $1
    local -i left_len=$REPLY
    prompt_length $2 9999
    local -i right_len=$REPLY
    local -i pad_len=$((COLUMNS - left_len - right_len - ${ZLE_RPROMPT_INDENT:-1}))
    if (( pad_len < 1 )); then
        # Not enough space for the right part. Drop it.
        echo "$1"
    else
        local pad=${(pl.$pad_len.. .)}  # pad_len spaces
        echo "${1}${pad}${2}"
    fi
}

###
# Usage: prompt_length PROMPT
# Determines the length of the outputted text of a string with zsh prompt syntax
###
function prompt_length() {
    emulate -L zsh
    local -i COLUMNS=${2:-COLUMNS}
    local -i x y=${#1} m
    if (( y )); then
        while (( ${${(%):-$1%$y(l.1.0)}[-1]} )); do
            x=y
            (( y *= 2 ))
        done
        while (( y > x + 1 )); do
            (( m = x + (y - x) / 2 ))
            (( ${${(%):-$1%$m(l.x.y)}[-1]} = m ))
        done
    fi
    typeset -g REPLY="$x"
}

hydrogen_theme
