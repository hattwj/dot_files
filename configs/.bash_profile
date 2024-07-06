pf1="$HOME/.bashrc"
pf3="$HOME/.bash_custom"


# Load custom bash script
[[ -e $pf3 ]] && source $pf3

# Load the right bashrc for this OS
[[ -e $pf1 ]] && source $pf1

# >>> JVM picker - set java home based on whatever is in path >>>
export JAVA_HOME="$(/usr/bin/env java -XshowSettings:properties -version 2>&1 | grep "java.home" | sed -e 's/java.home = //;s/ //g;')"
export PATH="$JAVA_HOME/bin:$PATH"
# <<< JVM picker <<<
