# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# >>> JVM picker - set java home based on whatever is in path >>>
export JPATH="/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.412.b08-1.amzn2.0.1.x86_64/bin/java"
export JAVA_HOME="$($JPATH -XshowSettings:properties -version 2>&1 | grep "java.home" | sed -e 's/java.home = //;s/ //g;')"
export PATH="$JAVA_HOME/bin:$PATH"
# <<< JVM picker <<<
