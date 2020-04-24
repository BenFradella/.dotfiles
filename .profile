#!/bin/sh

export TMOUT=0

export VISUAL=nvim
export EDITOR="$VISUAL"
export TERMINAL=konsole

[[ "${PATH}" == *"${HOME}/.local/bin"* ]] || export PATH="${PATH}:${HOME}/.local/bin"

export SSH_AUTH_SOCK="/run/user/1000/ssh-agent.socket"

if [[ -f /usr/bin/virtualenvwrapper.sh ]] ; then
# Enable virtualenvwrapper (added by vl_setup)
source /usr/bin/virtualenvwrapper.sh
fi
