#!/bin/bash
#
# rsdns-show.sh - Show record details
#

# config file for variables.
if [ -e ~/.rsdns_config ]
then
  . ~/.rsdns_config
fi

# load up our auth & funct library
if [ -n "$RSPATH" ]
then
  . $RSPATH/lib/auth.sh
  . $RSPATH/lib/func.sh
else
  . lib/auth.sh
  . lib/func.sh
fi

#prints out the usage information on error or request.
function usage () {
    printf "\n"
    printf "rsdns show -u username -a apiKey -d domain -i id \n"
    printf "\t-k Use London/UK Servers.\n"
    printf "\t-J Output in JSON (raw RS API data)\n"
    printf "\t-h Show this.\n"
    printf "\n"
}

#prints words for master rsdns script output
function words () {
    printf "Show DNS record details \n"
}

#Get options from the command line.
while getopts "u:a:c:d:i::hkqxwJ" option
do
    case $option in
        u    ) RSUSER=$OPTARG ;;
        a    ) RSAPIKEY=$OPTARG ;;
        c    ) USERID=$OPTARG ;;
        d    ) DOMAIN=$OPTARG ;;
        i    ) RECORDID=$OPTARG ;;
        h    ) usage;exit 0 ;;
        q    ) QUIET=1 ;;
        k    ) UKAUTH=1 ;;
        w    ) words;exit 0 ;;
        J    ) RSJSON=1 ;;
    esac
done

#Check for enough variables, print usage if not enough.
if [ $# -lt 2 ]
    then
    usage
    exit 1
fi

if [ -z $DOMAIN ]
    then
    usage
    exit 1
fi

if [ -z $RECORDID ]
    then
    usage
    exit 1
fi

#All actions require authentication, get it done first.
#If the authentication works this will return $TOKEN and $MGMTSVR for use by everything else.
get_auth $RSUSER $RSAPIKEY
if test -z $TOKEN
    then
    if [[ $QUIET -eq 0 ]]; then
        echo Auth Token does not exist.
    fi
    exit 98
fi
if test -z "$MGMTSVR"
    then
    if [[ $QUIET -eq 0 ]]; then
        echo Management Server does not exist.
    fi
    exit 97
fi

# get the domain ID :)
check_domain

RC=`curl -A "rsdns/$RSDNS_VERSION (https://github.com/linickx/rsdns)" -k -s -X GET -H X-Auth-Token:\ $TOKEN -H Content-Type:\ application/json  -H Accept:\ application/json $DNSSVR/$USERID/domains/$DOMAINID/records/$RECORDID |tr -s '[:cntrl:]' "\n"`
rackspace_cloud

#done
exit 0
