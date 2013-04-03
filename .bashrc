# General stuff here

# Make paging in postgres much nicer
export PAGER=less
export LESS="-iMSx4 -FX"


pf1="$HOME/.bashrc_"`uname`
pf2="$HOME/.bashrc_"`uname`'_'`hostname`

# Make sure we include .inputrc
[[ -f "~/.inputrc" ]] && export INPUTRC="~/.inputrc"

# Load the right bashrc for this OS
[[ -f $pf1 ]] && source $pf1
              
# Load the right bashrc for this machine
[[ -f $pf2 ]] && source $pf2

# Not entirely sure, but I dont think this is needed
#PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
