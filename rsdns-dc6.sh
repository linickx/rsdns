#!/bin/bash
#
# rsdns-dc.sh - A Dynamic DNS Client for rackspace cloud DNS
#

# config file for variables.
if [ -e ~/.rsdns_config ]
then
  . ~/.rsdns_config
else
  printf "\n"
  printf "No config file found. Please see REAME.md"
  printf "\n"
  exit
fi

# load up our auth & funct library
if [ -e $RSPATH/lib/auth.sh ]
then
  . $RSPATH/lib/auth.sh
else
  printf "\n"
  printf "auth.sh not found, please check you RSPATH"
  printf "\n"
  exit
fi

if [ -e $RSPATH/lib/func.sh ]
then
  . $RSPATH/lib/func.sh
else
  printf "\n"
  printf "func.sh not found, please check you RSPATH"
  printf "\n"
  exit
fi

# Check for additional dependency
check_dep "dig"


#prints out the usage information on error or request.
function usage () {
	printf "\n"
	printf "rscurl -n name \n"
	printf "\t-h Show this.\n"
	printf "\t-q Quiet.\n"
	printf "\n"
	printf "PLEASE NOTE: You need a ~/.rsdns_config config file, see README.md for Help!"
	printf "\n"
}

#prints words for master rsdns script output 
function words () {
	printf "Dynamic DNS Client for rackspace cloud DNS \n"
}

#Get options from the command line.
while getopts "n:H::hqw" option
do
	case $option in
		n	) NAME=$OPTARG ;;
		H	) HOST=$OPTARG ;;
		h	) usage;exit 0 ;;
		q	) QUIET=1 ;;
		w	) words;exit 0 ;;
	esac
done

# need a hostname.
if [ -z $NAME ]
    then
    usage
    exit 1
fi

# Only run if the internet is avilable

if [ -z $HOST ]
    then
    HOST="www.google.com"
fi

if ! ping6 -c 3 $HOST &>/dev/null  
then 
	if [[ $QUIET -eq 0 ]]; then
		echo "The Internet is down, cannot ping6 $HOST"
	fi
	exit
fi

# get and set our current IP address
IP=`curl -s -k http://ipv6.icanhazip.com`

# Check the RS DNS servers for the current A Record
AAAARECORD=`dig @ns.rackspace.com +short -t aaaa $NAME`

# if the IP doesn't match the A record update :)
if [ "$IP" != "$AAAARECORD" ];
then

	# Authenticate and get started
	get_auth $RSUSER $RSAPIKEY
	if test -z $TOKEN
		then 
		if [[ $QUIET -eq 0 ]]; then
			echo Auth Token does not exist.
		fi
		exit 98
	fi
	if test -z $MGMTSVR
		then 
		if [[ $QUIET -eq 0 ]]; then
			echo Management Server does not exist.
		fi
		exit 98
	fi

	# what domain does the host belong to?
	get_domain $NAME

	# set our record type
	RECORDTYPE="AAAA"

	# find the record ID for our $NAME
	get_recordid
	# get_recordid will bail if $NAME is not found, this is to stop cron jobs from creating many many records.

	# POST!
	RSPOST=`echo '{ "name" : "'$NAME'", "data" : "'$IP'" }'`
  
	RC=`curl -k -s -X PUT -H X-Auth-Token:\ $TOKEN -H Content-Type:\ application/json  -H Accept:\ application/json $DNSSVR/$USERID/domains/$DOMAINID/records/$RECORDID --data "$RSPOST" |tr -s '[:cntrl:]' "\n"`
            
	if [[ $QUIET -eq 0 ]]; then
		echo $RC
	fi
fi
#done.
