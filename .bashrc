# General stuff here

# Make paging in postgres much nicer
export PAGER=less
export LESS="-iMSx4 -FX"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
pf1="$DIR/.bashrc_"`uname`
pf2="$DIR/.bashrc_"`uname`'_'`hostname`

# custom tweaks not meant to be included in version control
pf3="$DIR/.bash_custom"

# Make sure we include .inputrc
[[ -f "~/.inputrc" ]] && export INPUTRC="~/.inputrc"

# Load the right bashrc for this OS
[[ -f $pf1 ]] && source $pf1
              
# Load the right bashrc for this machine
[[ -f $pf2 ]] && source $pf2

# Not entirely sure, but I dont think this is needed
#PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

