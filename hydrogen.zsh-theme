setopt PROMPT_SUBST

function main() {
    set_colours

    PROMPT='$(fill_line "$(top_right_part)" "$(gitstatus)      ")'
    PROMPT+=$'\n'
    PROMPT+='└ '

    # If the last exit code is > 0, the integer between brackets will be coloured
    # red, otherwise green (indicating success)
    RPROMPT="[%(?.${FG_RPROMPT}%?${FG_CLR}.${FG_RED}%?${FG_CLR})]"
}

function set_colours() {
    # FG = ForeGround
    FG_CLR='%F{default}'

    FG_RPROMPT='%F{34}'
    FG_USERNAME='%F{167}'
    FG_HOSTNAME='%F{67}'
    FG_PATH="%F{43}"
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

# Pressing UP and DOWN keys will go up and down in the entries in hitory that
# start with what has already been typed in
function search_history_with_text_already_inputted() {
    bindkey "${terminfo[kcuu1]}" history-substring-search-up
    bindkey "${terminfo[kcud1]}" history-substring-search-down
}

function set_tab_completion_menu_bindings() {
    # Highlight current entry in the tab completion menu
    zstyle ':completion:*' menu select
    zmodload zsh/complist

    # Use hjkl to navigate tab completion menu
    bindkey -M menuselect "h" vi-backward-char
    bindkey -M menuselect "j" vi-down-line-or-history
    bindkey -M menuselect "k" vi-up-line-or-history
    bindkey -M menuselect "l" vi-forward-char

    # Use Ctrl-[N|P] to navigate tab completion menu
    bindkey '^N' expand-or-complete
    bindkey '^P' reverse-menu-complete
}

function set_key_bindings() {
    # Enable vim mode
    bindkey -v

    # Remove character under cursor when the <Delete> key is pressed
    bindkey "^[[3~" vi-delete-char
    bindkey -a "^[[3~" vi-delete-char

    # Move just a character when Ctrl-[LEFT|RIGHT] is pressed
    bindkey "^[[1;5D" backward-char
    bindkey "^[[1;5C" forward-char

    search_history_with_text_already_inputted

    set_tab_completion_menu_bindings
}
set_key_bindings

# Use LS_COLORS when completing filenames
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

main
