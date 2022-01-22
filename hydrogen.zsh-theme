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

###
# usage: hydrogen_theme
# Set PROMPT and RPROMPT to display the theme
###
function hydrogen_theme() {
    setopt PROMPT_SUBST
    set_colours

    PROMPT='$(fill_line "$(top_left_part)" "$(gitstatus)      ")'
    PROMPT+=$'\n'
    PROMPT+='└ '

    # If the last exit code is > 0, the integer between brackets will be coloured
    # red, otherwise green (indicating success)
    RPROMPT="[%(?.${HYDROGEN_GREEN}%?${HYDROGEN_CLR}.${HYDROGEN_RED}%?${HYDROGEN_CLR})]"
}

###
# usage: set_colours
# Export global variables that hydrogen uses. If terminal isn't capable of
# handling more than 256 colours, use standard 8 bit palette
###
function set_colours() {
    export HYDROGEN_CLR='%F{default}'

    if [[ $(tput colors) -ge 256 ]]; then
        export HYDROGEN_USERNAME='%F{167}'
        export HYDROGEN_HOSTNAME='%F{67}'
        export HYDROGEN_PATH="%F{43}"
        export HYDROGEN_GREEN='%F{34}'
        export HYDROGEN_RED='%F{9}'
    else
        export HYDROGEN_USERNAME='%F{red}'
        export HYDROGEN_HOSTNAME='%F{blue}'
        export HYDROGEN_PATH="%F{cyan}"
        export HYDROGEN_GREEN='%F{green}'
        export HYDROGEN_RED='%F{red}'
    fi
}

###
# usage: top_left_part
# Print the top left part of the prompt to stdout, with all variables expanded
###
function top_left_part()
{
    # Username and hostname
    SECTION_A="(${HYDROGEN_USERNAME}%n${HYDROGEN_CLR}@${HYDROGEN_HOSTNAME}%m${HYDROGEN_CLR})"
    # Path
    SECTION_B="${HYDROGEN_PATH}%~${HYDROGEN_CLR}"

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
