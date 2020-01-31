pf1="$HOME/.bashrc"
pf3="$HOME/.bash_custom"


# Load custom bash script
[[ -e $pf3 ]] && source $pf3

# Load the right bashrc for this OS
[[ -e $pf1 ]] && source $pf1
