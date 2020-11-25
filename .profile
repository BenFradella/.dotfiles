#!/bin/sh

export TMOUT=0

export VISUAL=nvim
export EDITOR="$VISUAL"
export TERMINAL=konsole

[[ "${PATH}" == *"${HOME}/.local/bin"* ]] || export PATH="${PATH}:${HOME}/.local/bin"

if [[ -f "${HOME}/.ssh/solidfire_dev_rsa" ]] ; then
	eval $(ssh-agent)
	DISPLAY= SSH_ASKPASS= ssh-add "${HOME}/.ssh/solidfire_dev_rsa"
fi
