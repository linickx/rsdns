#!/bin/bash
#
# rsdns-version.sh - Prints the Version
#

# load up our auth & funct library
if [ -n "$RSPATH" ]
then
  . $RSPATH/lib/func.sh
else
  . lib/func.sh
fi

#prints words for master rsdns script output 
function words () {
	printf "Prints the version number of rsdns \n"
}

function usage () {
    printf "\n"
	printf "rsdns version -s \n"
    printf "\t-s Prints just the short version number \n"
    printf "\t-h Show this.\n"
    printf "\n"
}

function version() {
    printf "$1$RSDNS_VERSION\n"
}

#Get options from the command line.
while getopts "::hws" option
do
	case $option in
		h	) usage;exit 0 ;;
		w	) words;exit 0 ;;
        s	) version;exit 0 ;;
	esac
done

version "Version "