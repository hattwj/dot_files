# General stuff here

# Make paging in postgres much nicer
export PAGER=less
export LESS="-iMSx4 -FX"


pf1="$HOME/.bashrc_"`uname`
pf2="$HOME/.bashrc_"`uname`'_'`hostname`


# Load the right bashrc for this OS
if [ -f $pf1 ] ; then 
    source $pf1
fi
              
# Load the right bashrc for this machine
if [ -f $pf2 ];  then 
    source $pf2
fi

