#!/bin/bash
# This is a convenience to download the latest node-webkit zips.

# Go into script's directory for this subshell.
cd "$(dirname "$BASH_SOURCE")"

nwjs='nwjs' # Path to local NW.js install.

showHelp() {
    echo 'This script checks and downloads NW.js builds.'
    echo 'Usage'
    echo "    $(basename "$BASH_SOURCE") [option]"
    echo 'Options:'
    echo '    -h | --help   : show this help.'
    echo '    -v | --verify : Verify latest version from the server and print it.'
    exit 0
}

current() {
    if [[ -f "$nwjs/version.txt" ]]; then
        cat "$nwjs/version.txt"
    else
        echo 'none'
    fi
}

verify() {
    # Downloads server.
    server='http://dl.nwjs.io'

    # Get all the MD5 hashes with paths from the server
    sums="$(wget -qO- $server/MD5SUMS)"

    # If there was an error with that, we can't go on.
    if (($?)); then
        echo "There was a problem getting the MD5SUMS from $server"
        exit 1
    fi

    # Get the currently available versions from the hash list.
    versions="$(echo "$sums" | cut -c 35- | cut -d/ -f 1 | sort | uniq | grep -v '^\.$')"

    # Note about this: we do not want any version that looks like an alpha release.
    versions="$(echo "$versions" | grep -vE 'alpha|nightly|live')"

    # Semver sorts the versions, last line will be latest version.
    latest="$(./node_modules/.bin/semver $versions | tail -n1)"

    # Output the result.
    echo "Latest server version: $latest"
    echo "Current local version: $(current)"
}

case "$1" in
    -h | --help)
        showHelp ;;
    -v | --verify )
        verify ;;
    *)
        echo 'Unrecognized command. See --help.' ;;
esac
