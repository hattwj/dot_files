pf1="$HOME/.bashrc"
pf3="$HOME/.bash_custom"


# Load custom bash script
[[ -e $pf3 ]] && source $pf3

# Load the right bashrc for this OS
[[ -e $pf1 ]] && source $pf1

# >>> JVM picker - set java home based on whatever is in path >>>
export JPATH="/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.412.b08-1.amzn2.0.1.x86_64/bin/java"
export JAVA_HOME="$($JPATH -XshowSettings:properties -version 2>&1 | grep "java.home" | sed -e 's/java.home = //;s/ //g;')"
export PATH="$JAVA_HOME/bin:$PATH"
# <<< JVM picker <<<
