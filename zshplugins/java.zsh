jdk() {
  version=$1
  if [[ -z $version ]]; then
    echo "Usage: jdk <version>"
    echo
    echo "Available versions:"
    /usr/libexec/java_home -V
    echo
    echo "Current version: $JAVA_HOME"
    return 1
  fi

  # Big Sur bug: https://developer.apple.com/forums/thread/666681
  unset JAVA_HOME
  export JAVA_HOME=$(/usr/libexec/java_home -v"$version")
  java -version
}
