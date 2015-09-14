# General stuff here

# Make paging in postgres much nicer
export PAGER=less
export LESS="-iMSx4 -FX"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

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

## Hidden hostname?
# Hard to manage
# Easy to hack
# Not worth it
# hostname_md5=`lsb_release -si`-`hostname`-`uname -m` | md5sum | awk '{print $1}'
# Touch file if it does not exist


pf1="$DIR/.bashrc_"`uname`
pf2="$DIR/.bashrc_"`uname`'_'`hostname`

# custom tweaks not meant to be included in version control
# Create file if missing
# pf3="$DIR/tmp/bash_custom"
pf3="~/.bash_custom"

# Make sure we include .inputrc
[[ -f "~/.inputrc" ]] && export INPUTRC="~/.inputrc"

# Load the right bashrc for this OS
[[ -f $pf1 ]] && source $pf1
              
# Load the right bashrc for this machine
[[ -f $pf2 ]] && source $pf2

# Load custom bash script
[[ -f $pf3 ]] && source $pf3

# Not entirely sure, but I dont think this is needed
#PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

