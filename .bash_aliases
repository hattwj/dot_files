alias serve='python -m SimpleHTTPServer'
alias cls="echo -ne '\033c'"
alias tmux="TERM=xterm-256color tmux"
alias git-is-slow-again='git gc;git repack -a -d --depth=250 --window=250;git prune'

##
# Force git to reset stuck files that are showing as modified
function git-is-not-resetting-to()
{
  [ -z "$1" ] && echo "
Error: remote/branch argument is required
For example:  
  git-is-not-resetting-to origin/master

" && return 0
  echo "This command will remove all changes in the working copy"
  read -p "Confirm to continue: (Yy)" -n 1 -r
  echo    # (optional) move to a new line
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    pushd $(git rev-parse --show-toplevel)
      git rm --cached -r .
      git reset --hard $1
    popd
  fi

}

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias lsnet='netstat -tulpn'

# Alias ack-grep for ubuntu
if hash ack-grep 2>/dev/null; then
    alias ack='ack-grep'
fi

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
if hash notify-send 2>/dev/null; then
    alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
fi

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

function rspec-grouped-failures()
{
  # Call rspec and forward parameters to rspec
  # get report on failures
  bundle exec rspec $@| \
    # remove details of failures
    sed -e '/Failed\ examples:/,$!d'| \
    # remove anything that does not start with "rspec"
    sed -r -e '/^rspec/!d'| \
    # strip all trailing details except filename
    sed -r -e 's/:[0-9].+*$/ /'| \
    sort| \
    # Generate counts
    uniq -c | \
    # Natural sort, order by failure count
    sort -n | \
    # Calculate total and add it to the end
    awk '{sum+=$1 ; print $0} END{print "Total:",sum}'
}
