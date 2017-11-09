#!/usr/bin/env bash
#
# helper to correctly do a 'dnf install' inside a Vagrantfile's provision
#
# the upstream mirrors sometimes fail so this will retry up to 5 times
#
# todo: this is copypasta with bwstitt/library-ubuntu/src/
#

set -e

function retry {
    # inspired by:
    # http://unix.stackexchange.com/questions/82598/how-do-i-write-a-retry-logic-in-script-to-keep-retrying-to-run-it-upto-5-times
    local n=1
    local max=5
    local delay=5
    while true; do
        echo "Attempt ${n}/${max}: $@"
        "$@"
        local exit_code=$?

        if [ "$exit_code" -eq 0 ]; then
            echo "Attempt ${n}/${max} was successful"
            break
        elif [[ $n -lt $max ]]; then
            echo "Attempt ${n}/${max} exited non-zero ($exit_code)"
            ((n++))
            echo "Sleeping $delay seconds..."
            sleep $delay;
        else
            echo "Attempt ${n}/${max} exited non-zero ($exit_code). Giving up"
            return $exit_code
        fi
    done
}

if [ -n "$HTTP_PROXY" ]; then
    echo "Configuring dnf to use HTTP_PROXY..."
    cp /etc/dnf/dnf.conf /etc/dnf/dnf.conf.bac
    echo "proxy=$HTTP_PROXY" >>/etc/dnf/dnf.conf
fi

echo
echo "Downloading packages..."
retry dnf install -y --downloadonly "$@"

echo
echo "Installing packages..."
dnf install -y "$@"

# TODO: make cleaning optional. for the ISO builder image, we want to keep the cache populated
echo
echo "Cleaning up..."
dnf clean all

if [ -e /etc/dnf/dnf.conf.bac ]; then
    mv /etc/dnf/dnf.conf.bac /etc/dnf/dnf.conf
fi
