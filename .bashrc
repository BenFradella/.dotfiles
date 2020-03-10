#
# ~/.bashrc
#

[[ $- != *i* ]] && return

[ -r /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion

# Change the window title of X terminals
case ${TERM} in
    xterm*|rxvt*|Eterm*|aterm|kterm|gnome*|interix|konsole*)
        PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\007"'
        ;;
    screen*)
        PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\033\\"'
        ;;
esac

use_color=true

# Set colorful PS1 only on colorful terminals.
# dircolors --print-database uses its own built-in database
# instead of using /etc/DIR_COLORS.  Try to use the external file
# first to take advantage of user additions.  Use internal bash
# globbing instead of external grep binary.
safe_term=${TERM//[^[:alnum:]]/?}   # sanitize TERM
match_lhs=""
[[ -f ~/.dir_colors   ]] && match_lhs="${match_lhs}$(<~/.dir_colors)"
[[ -f /etc/DIR_COLORS ]] && match_lhs="${match_lhs}$(</etc/DIR_COLORS)"
[[ -z ${match_lhs}    ]] \
    && type -P dircolors >/dev/null \
    && match_lhs=$(dircolors --print-database)
[[ $'\n'${match_lhs} == *$'\n'"TERM "${safe_term}* ]] && use_color=true

if ${use_color} ; then
    # Enable colors for ls, etc.  Prefer ~/.dir_colors #64489
    if type -P dircolors >/dev/null ; then
        if [[ -f ~/.dir_colors ]] ; then
            eval $(dircolors -b ~/.dir_colors)
        elif [[ -f /etc/DIR_COLORS ]] ; then
            eval $(dircolors -b /etc/DIR_COLORS)
        fi
    fi

    if [[ ${EUID} == 0 ]] ; then
        PS1="\[\e[1;31m\][\h\[\e[1;36m\] \W\[\e[1;31m\]]\$\[\e[0m\] "
    else
        [[ -f ~/.bash/.colors ]] && source ~/.bash/.colors
        : ${PS1_FG1:=30}  # black
        : ${PS1_BG1:=42}  # green
        : ${PS1_FG2:=97}  # white
        : ${PS1_BG2:=100} # grey
        E0B0=$'\uE0B0'
        color_1="\[\e[${PS1_FG1};${PS1_BG1}m\]"
        color_2="\[\e[$((PS1_BG1-10));${PS1_BG2}m\]"
        color_3="\[\e[${PS1_FG2}m\]"
        color_4="\[\e[0;$((PS1_BG2-10))m\]"
        color_reset="\[\e[0m\]"
        PS1="${color_1} \u@\h ${color_2}${E0B0}${color_3} \W ${color_4}${E0B0}${color_reset} "
        unset PS1_{FG1,BG1,FG2,BG2} E0B0 color_{1,2,3,4,reset}
    fi

    alias ls='ls --color=auto'
    alias grep='grep --colour=auto'
    alias egrep='egrep --colour=auto'
    alias fgrep='fgrep --colour=auto'
else
    if [[ ${EUID} == 0 ]] ; then
        # show root@ when we don't have colors
        PS1="\u@\h \W \$ "
    else
        PS1="\u@\h \w \$ "
    fi
fi

unset use_color safe_term match_lhs sh

export VISUAL=nvim
export EDITOR="$VISUAL"

xhost +local:root > /dev/null 2>&1

complete -cf sudo

# Bash won't get SIGWINCH if another process is in the foreground.
# Enable checkwinsize so that bash will check the terminal size when
# it regains control.  #65623
# http://cnswww.cns.cwru.edu/~chet/bash/FAQ (E11)
shopt -s checkwinsize

shopt -s expand_aliases

# export QT_SELECT=4

# Enable history appending instead of overwriting.  #139609
shopt -s histappend

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

# enable extended globbing expressions 
shopt -s extglob

[[ -f ~/.bash_aliases ]] && source ~/.bash_aliases
