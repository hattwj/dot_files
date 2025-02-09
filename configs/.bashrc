# General stuff here

# Make paging in postgres much nicer
export PAGER='less -r'
export LESS="-iMSx4 -FX"

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

##
# Plan:
# Remove period (.) from all files in dot_files
# Add scripts directory to PATH
# Create env file for paths and constants
# Add ack to path
# Rework bash file naming conventions
## Eg.
# lsb_release -si       # OS name
# lsb_release -sr       # OS version
# uname -m              # CPU Architecture
# ./bashrc_aliases
# ./bashrc_$OSName
# ./bashrc_$OSName_$OSVer
# ./bashrc_$OSName_$ARCH
# ./bashrc_$hostname_md5

pf1="$DIR/.bashrc_"$(uname)
pf2="$DIR/.bashrc_"$(uname)'_'$(hostname)
pf3="$HOME/.bash_custom"

# Make sure we include .inputrc
[[ -e "$HOME/.inputrc" ]] && export INPUTRC="$HOME/.inputrc"

# Load the right bashrc for this OS
[[ -e $pf1 ]] && source $pf1

# Load the right bashrc for this machine
[[ -e $pf2 ]] && source $pf2

# Load custom bash script
[[ -e $pf3 ]] && source $pf3

# Not entirely sure, but I dont think this is needed
#PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

if [ -d "$HOME/.rbenv/bin" ]; then 
  export PATH=$HOME/.rbenv/bin:$PATH
  eval "$(rbenv init -)"
fi

[[ -s "$HOME/.local/bin/mise" ]] && eval "$($HOME/.local/bin/mise activate bash)"

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

[ -d "$HOME/.toolbox/bin" ] && export PATH=$HOME/.toolbox/bin:$PATH
