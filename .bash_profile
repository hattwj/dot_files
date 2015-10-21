pf1="$HOME/.bashrc"
pf3="$HOME/.bash_custom"


# Load custom bash script
[[ -f $pf3 ]] && source $pf3

# Load the right bashrc for this OS
[[ -f $pf1 ]] && source $pf1

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
