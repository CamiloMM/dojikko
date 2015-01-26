#!/bin/bash
# This is a convenience to download the latest node-webkit zips.

# Go into script's directory for this subshell.
cd "$(dirname "$BASH_SOURCE")"

# Path to local NW.js install.
nwjs='nwjs'

# Downloads server.
server='http://dl.nwjs.io'

# Platforms that we care about. Space-separated list containing one or
# more of: linux-ia32, linux-x64, osx-ia32, osx-x64, win-ia32, win-x64.
platforms='win-ia32 win-x64'

# Shows a help text and exits.
showHelp() {
    echo 'This script checks and downloads NW.js builds.'
    echo 'Usage'
    echo "    $(basename "$BASH_SOURCE") [option]"
    echo 'Options:'
    echo '    -h | --help   : show this help.'
    echo '    -v | --verify : Verify latest version from the server and print it.'
    echo '    -u | --update : Check, download and update to latest version if needed.'
    exit 0
}

# Returns a (cached) copy of the MD5SUMS from the server.
getMD5Sums() {
    # Cache.
    if [[ -n "$MD5SUMS" ]]; then
        echo "$MD5SUMS"
        return
    fi

    # I hope these guys keep consistency.
    MD5SUMS="$(wget -qO- $server/MD5SUMS)"

    # If there was an error with that, we can't go on.
    if (($?)); then
        echo "There was a problem getting the MD5SUMS from $server"
        exit 1
    fi

    echo "$MD5SUMS"
}

# Returns current (local) version of NW.js, or "none".
getCurrent() {
    if [[ -f "$nwjs/version.txt" ]]; then
        cat "$nwjs/version.txt"
    else
        echo 'none'
    fi
}

# Gets the latest version available from the server.
getLatest() {
    # Get all the MD5 hashes with paths from the server
    sums="$(getMD5Sums)"

    # Get the currently available versions from the hash list.
    versions="$(echo "$sums" | cut -c 35- | cut -d/ -f 1 | sort | uniq | grep -v '^\.$')"

    # Note about this: we do not want any version that looks like an alpha release.
    versions="$(echo "$versions" | grep -vE 'alpha|nightly|live')"

    # Semver sorts the versions, last line will be latest version.
    ./node_modules/.bin/semver $versions | tail -n1
}

# Checks if we should update the version, based on
# local version and server version as $1 and $2.
# Return code zero means we should update.
shouldUpdate() {
    if [[ "$1" == 'none' ]]; then
        true
    else
        ./node_modules/.bin/semver "$2" -r \>"$1" > /dev/null
    fi
}

# Verifies and prints remote and local versions, and says if we should update.
verify() {
    latest=$(getLatest);
    current=$(getCurrent);

    # Output the result.
    echo "Latest server version: $latest"
    echo "Current local version: $current"

    # Say if we should update.
    if shouldUpdate "$current" "$latest"; then
        echo 'We should update to the latest version.'
    else
        echo 'Local version is up-to-date.'
    fi
}

update() {
    latest=$(getLatest);
    current=$(getCurrent);

    if shouldUpdate "$current" "$latest"; then
        for i in $platforms; do
            download "$latest" "$i"
        done
    fi
}

# Downloads a version from the server.
download() {
    # Provide "version" and "platform" parameters.
    version="$1"
    platform="$2"

    # TODO
}

# Run according to given arguments.
case "$1" in
    -h | --help)
        showHelp ;;
    -v | --verify )
        verify ;;
    -u | --update )
        update ;;
    *)
        echo 'Unrecognized command. See --help.' ;;
esac
