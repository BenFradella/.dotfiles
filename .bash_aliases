#!/bin/bash

expand_alias()
{
    local alias=$({ alias $1 || echo $1; } 2>/dev/null)
    echo "${alias#*=}"
}

if which lsd &>/dev/null ; then
    alias ll="lsd -halF --group-dirs=first"
    alias tree="lsd -AF --group-dirs=first --tree"
else
    alias ll="$(expand_alias ls) -halF --group-directories-first"
fi

alias repwd='cd "${PWD}"' # refresh pwd when it gets pulled out from unerneath you

alias check_IFS="[[ \"\${IFS}\" == $' \t\n' ]] && echo true || echo false"
alias reset_IFS="IFS=$' \t\n'"

# regurgitate the input with entries seperated by the specified character
OFS()
{
    local IFS=$1 ; shift
    echo "$*"
}

for_each()
{
    local action="$1" ; shift
    local it
 
    eval 'until [[ $# == 0 ]] ; do
        it="$1"
        if [[ -p "${it}" ]] ; then
            # "it" is a named pipe. Read items from it. `for_each "..." <(...`
            while read it ; do
                '"${action}"'
            done < ${it}
        else
            # "it" is a literal
            '"${action}"'
        fi
        shift
    done
    # No explicit arguments. Check if any are being piped to us
    while read it ; do
        '"${action}"'
    done'
}

any()
{
    local condition="$1" ; shift
    for_each "${condition} && return 0" "$@"
}

all()
{
    local condition="$1" ; shift
    for_each "${condition} || return 1" "$@"
}

__zip_internal()
{
    local truncate=$1 ; shift
    local with; [[ $# == 3 ]] && { with="$1" ; shift; }

    for array in array{1,2} ; do
        if [[ $(declare -p $1 2>/dev/null) =~ declare\ -a ]] ; then
            # arg is the name of an array
            local -n ${array}=$1
        elif [[ -p $1 ]] ; then
            # arg is a named pipe. `zip <(...'
            local ${array}
            read -a ${array} < $1
        elif [[ $(declare -p $1 2>/dev/null) =~ declare\ -A ]] ; then
            echo "__zip_internal: associative arrays are not currently supported"; return 1
        else
            echo "__zip_internal: expected the name of an array or an fd, got: \`$1'" ; return 1
        fi
        shift
    done

    local indexes1=( ${!array1[@]} )
    local indexes2=( ${!array2[@]} )

    if ${truncate} ; then
        # Figure out how long to make the output array.
        # Use the shorter of the two input arrays' lengths.
        local len1=${#array1[@]}
        local len2=${#array2[@]}
        local len=$(( len1 < len2 ? len1 : len2 ))

        # Iterate over the indexes of the individual arrays.
        # This lets us handle sparse input arrays nicely.
        local i1 i2 out
        for ((i=0; i<len; i++)) ; do
            i1=${indexes1[$i]}
            i2=${indexes2[$i]}
            out[$i]="${array1[$i1]}${with:-}${array2[$i2]}"
        done
    else
        # Figure out how long to make the output array.
        # This time we use the last set index for the length of each array,
        #   and we use the larger one as our output length.
        local last1=${indexes1[-1]}
        local last2=${indexes2[-1]}
        local len=$(( last1 > last2 ? last1+1 : last2+1 ))

        local maybe_with out
        for ((i=0; i<len; i++)) ; do
            # If both arrays aren't set at this index, don't print anything between them.
            [[ -v array1[$i] && -v array2[$i] ]] && maybe_with="${with}" || maybe_with=""
            out[$i]="${array1[$i]:-}${maybe_with}${array2[$i]:-}"
        done
    fi

    echo "${out[@]}"
}

alias zipf="__zip_internal false"  # zip full
alias zips="__zip_internal true"   # zip short

################################################################################
#
# solidfire-specific stuff
#
################################################################################

alias vl_update="vl_setup update && pipenv update && pip install --upgrade pylint"
alias sfssh="ssh -o StrictHostKeyChecking=no -o IdentityFile=~/.ssh/solidfire_dev_rsa"

__source_internal()
{
    local shell=$1
    which ${shell} || return 1

    export ${shell^^}_HOME="$(dirname $(realpath $(which ${shell})))/.."

    until
        bash --init-file <(cat <<EOF
            source ~/.bash_profile
            SSH_CLIENT=''
            PS1="${PS1//\\u/$shell}"
            $(${shell} --source)
EOF
        )
    do
        echo "Continue? [1,2]"
        select cont in y n ; do
            [[ "${cont}" == n ]] && return || break
        done
    done
}

alias source_bashutils="__source_internal bashutils"
alias source_ebash="__source_internal ebash"
