#!/bin/sh

# Use the macports version to circumvent sqlite bug
SVNVERSION_PATH="/opt/local/bin/svnversion"
if [[ ! -e $SVNVERSION_PATH ]]
then
    SVNVERSION_PATH="/usr/local/bin/svnversion"
    if [[ ! -e $SVNVERSION_PATH ]]
    then
    # Use the system version (which is hopefully the latest …)
        SVNVERSION_PATH="/usr/bin/svnversion"
    fi
fi

if [[ ! -e $SVNVERSION_PATH ]]
then
    SVNVERSION_PATH=svnversion
fi

SVN_VERSION=$($SVNVERSION_PATH -c | cut -d ':' -f2 | tr -d MS)

echo "${SVN_VERSION}"
