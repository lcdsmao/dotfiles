jdk() {
    version=$1
    export JAVA_HOME=$(/usr/libexec/java_home -v"$version")
    java -version
}

# Set default JAVA_HOME
jdk 11 > /dev/null 2>&1
