#!/bin/sh

export TMOUT=0

export VISUAL=nvim
export EDITOR="$VISUAL"
export TERMINAL=konsole

for path in "${HOME}/.local/bin" "/usr/lib/go-1.14/bin" ; do
    [[ -e "${path}" && "${PATH}" != *"${path}"* ]] && export PATH="${PATH}:${path}"
done

if [[ -f "${HOME}/.ssh/solidfire_dev_rsa" ]] ; then
	eval $(ssh-agent)
	trap "kill ${SSH_AGENT_PID}" EXIT
	DISPLAY= SSH_ASKPASS= ssh-add "${HOME}/.ssh/solidfire_dev_rsa"
fi
