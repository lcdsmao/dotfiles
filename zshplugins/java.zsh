jdk() {
  version=$1
  # Big Sur bug: https://developer.apple.com/forums/thread/666681
  unset JAVA_HOME
  export JAVA_HOME=$(/usr/libexec/java_home -v"$version")
  java -version
}

# Set default JAVA_HOME
jdk 11 > /dev/null 2>&1
