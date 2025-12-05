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

# Array of rc files to source
rc_files=(
  "$DIR/.bashrc_$(uname)"
  "$DIR/.bashrc_$(uname)_$(hostname)"
  "$HOME/.bash_custom"
  "$HOME/.bash_prompt"
)

# Iterate over rc files and source them if they exist
for rc_file in "${rc_files[@]}"; do
  [[ -e "$rc_file" ]] && source "$rc_file"
done

# Make sure we include .inputrc
[[ -e "$HOME/.inputrc" ]] && export INPUTRC="$HOME/.inputrc"


# Special handling for mise (only if command exists)
command -v "mise" > /dev/null 2>&1 && [[ -e "$HOME/.bash_activate_mise.sh" ]] && source "$HOME/.bash_activate_mise.sh"

# Load nvm if available
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# Add toolbox to PATH if it exists
[ -d "$HOME/.toolbox/bin" ] && export PATH=$HOME/.toolbox/bin:$PATH

# Load cargo environment
[ -s "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
