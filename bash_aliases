# Make and change directory at once
unalias md 2>/dev/null
md () {
  mkdir -p "$1" && cd "$1"
}

# cd into directory on git clone
git() {
   local tmp=$(mktemp)
   local repo_name

   if [ "$1" = clone ] ; then
     /usr/bin/git "$@" 2>&1 | tee $tmp
     repo_name=$(awk -F\' '/Cloning into/ {print $2}' $tmp)
     rm $tmp
     printf "changing to directory %s\n" "$repo_name"
     cd "$repo_name"
   else
     /usr/bin/git "$@"
   fi
}
gh() {
   local tmp=$(mktemp)
   local repo_name

   if [ "$1" = clone ] ; then
     /usr/local/bin/gh "$@" 2>&1 | tee $tmp
     repo_name=$(awk -F\' '/Cloning into/ {print $2}' $tmp)
     rm $tmp
     printf "changing to directory %s\n" "$repo_name"
     cd "$repo_name"
   else
     /usr/local/bin/gh "$@"
   fi
}

function pushtmp() {
   tmp_dir=$(mktemp -d -t GAR-$(date +%Y-%m-%d-%H-%M-%S)-XXXX)
   pushd "$tmp_dir"
}

alias py=python3

# Change directories easily
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias .......='cd ../../../../../..'

alias dwn='pushd ~/storage/downloads'
alias root='pushd ~'

# Stop ctrl+s from freezing your terminal
stty stop ''

# Enable windows-style completion
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
      . /etc/bash_completion
fi

