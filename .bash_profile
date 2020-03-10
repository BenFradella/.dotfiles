#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && source ~/.bashrc

export SSH_AUTH_SOCK="/run/user/1000/ssh-agent.socket"

if [[ -f /usr/bin/virtualenvwrapper.sh ]] ; then
# Enable virtualenvwrapper (added by vl_setup)
source /usr/bin/virtualenvwrapper.sh
fi
