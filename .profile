#!/bin/sh

export TMOUT=0

export VISUAL=nvim
export EDITOR="$VISUAL"
export TERMINAL=konsole

for path in "${HOME}/.local/bin" "/usr/lib/go-1.14/bin" ; do
    [[ -e "${path}" && "${PATH}" != *"${path}"* ]] && export PATH="${PATH}:${path}"
done

if [[ -f "${HOME}/.ssh/solidfire_dev_rsa" ]] ; then
    if SSH_AGENT_PID=$(set -o pipefail; pgrep ssh-agent 2>/dev/null | head -1) ; then
        export SSH_AGENT_PID
        export SSH_AUTH_SOCK=$(compgen -G "/tmp/ssh-*/agent.$((SSH_AGENT_PID - 1))")
    else
        eval $(ssh-agent)
        DISPLAY= SSH_ASKPASS= ssh-add "${HOME}/.ssh/solidfire_dev_rsa"
    fi
fi

# Only for WSL
if [[ -e /etc/wsl.conf ]] ; then
    export DISPLAY="$(awk '/nameserver/ {print $2}' /etc/resolv.conf):0.0"
    export LIBGL_ALWAYS_INDIRECT=1
    pgrep dbus &>/dev/null || sudo /etc/init.d/dbus start
fi
