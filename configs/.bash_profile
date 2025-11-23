pf1="$HOME/.bashrc"

# Load the right bashrc for this OS
[[ -e $pf1 ]] && source $pf1

# >>> JVM picker - set java home based on whatever is in path >>>

# export JPATH="/usr/lib/jvm/java-1.8.0-openjdk/bin/java"
export JPATH="/usr/lib/jvm/jre-17/bin/java"
[[ -e $JPATH ]] && \
  export JAVA_HOME="$($JPATH -XshowSettings:properties -version 2>&1 | grep "java.home" | sed -e 's/java.home = //;s/ //g;')" && \
  export PATH="$JAVA_HOME/bin:$PATH"
# <<< JVM picker <<<
. "$HOME/.cargo/env"
