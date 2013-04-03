pf0="$HOME/.bashrc"
pf1="$HOME/.profile"

# Load the right bashrc for this OS
if [ -f $pf0 ] ; then 
    source $pf0
fi

# Load .profile if it exists
if [ -f $pf1 ] ; then 
    source $pf1
fi

