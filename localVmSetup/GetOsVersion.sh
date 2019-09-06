# Get the OS_NAME and its version
# source: https://unix.stackexchange.com/questions/6345/how-can-i-get-distribution-name-and-version-number-in-a-simple-shell-script

if [ -f /etc/lsb-release ]; then
    # For some versions of Debian/Ubuntu without lsb_release command
    . /etc/lsb-release
    OS_NAME=$DISTRIB_ID
    OS_VERS=$DISTRIB_RELEASE
elif [ -f /etc/os-release ]; then
    # freedesktop.org and systemd
    . /etc/os-release
    OS_NAME=$NAME
    OS_VERS=$VERSION_ID
elif type lsb_release >/dev/null 2>&1; then
    # linuxbase.org
    OS_NAME=$(lsb_release -si)
    OS_VERS=$(lsb_release -sr)
elif [ -f /etc/debian_version ]; then
    # Older Debian/Ubuntu/etc.
    OS_NAME=Debian
    OS_VERS=$(cat /etc/debian_version)
elif [ -f /etc/SuSe-release ]; then
    # Older SuSE/etc.
    # TODO
    echo "Unsupported operating system";
    exit 1;
elif [ -f /etc/redhat-release ]; then
    # Older Red Hat, CentOS_NAME, etc.
    # TODO
    exit 1;
else
    # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
    OS_NAME=$(uname -s)
    OS_VERS=$(uname -r)
fi

