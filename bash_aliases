# Make and change directory at once
md () {
  mkdir -p "$1" && cd "$1"
}

# cd into directory on git clone
git()
{
   local tmp=$(mktemp)
   local repo_name

   if [ "$1" = clone ] ; then
     /usr/bin/git "$@" | tee $tmp
     repo_name=$(awk -F\' '/Cloning into/ {print $2}' $tmp)
     rm $tmp
     printf "changing to directory %s\n" "$repo_name"
     cd "$repo_name"
   else
     /usr/bin/git "$@"
   fi
}

# Change directories easily
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias .......='cd ../../../../../..'

# Stop ctrl+s from freezing your terminal
stty stop ''

# Enable windows-style completion
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
      . /etc/bash_completion
fi

