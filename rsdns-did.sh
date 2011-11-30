#!/bin/bash
#
# rsdns-did.sh - did == Delete by ID - Used to create/delete records hosted on rackspace cloud dns by the record ID, tiz a bodge whilst I work stuff out!
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
	printf "rscurl -u username -a apiKey -d domain -i id \n"
	printf "\t-k Use London/UK Servers.\n"
	printf "\t-h Show this.\n"
	printf "\n"
}

#Get options from the command line.
while getopts "u:a:c:d:i::hkqx" option
do
	case $option in
		u	) RSUSER=$OPTARG ;;
		a	) RSAPIKEY=$OPTARG ;;
		c	) USERID=$OPTARG ;;
		d	) DOMAIN=$OPTARG ;;
		i	) ID=$OPTARG ;;
		h	) usage;exit 0 ;;
		q	) QUIET=1 ;;
		k	) UKAUTH=1 ;;
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

if [ -z $ID ]
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
if test -z $MGMTSVR
	then 
	if [[ $QUIET -eq 0 ]]; then
		echo Management Server does not exist.
	fi
	exit 98
fi

# get the domain ID :)
check_domain

  RC=`curl -k -s -X DELETE -D - -H X-Auth-Token:\ $TOKEN -H Content-Type:\ application/json  -H Accept:\ application/json $DNSSVR/$USERID/domains/$DOMAINID/records/$ID|tr -s [:cntrl:] "\n"`
  
  if [[ $QUIET -eq 0 ]]; then
    echo $RC
  fi

#done
exit 0
