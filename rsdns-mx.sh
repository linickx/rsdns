#!/bin/bash
#
# rsdns-mx.sh - Used to create/delete MX records hosted on rackspace cloud dns
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
	printf "rsdns mx -u username -a apiKey -d domain -n name -D data -p priority -t TTL\n"
	printf "\t-k Use London/UK Servers.\n"
	printf "\t-x Delete record.\n"
	printf "\t-h Show this.\n"
	printf "\n"
}


function create_mx () {
# { "id" : "MX-123", "priority" : 10, "type" : "MX", "name" : "example.foo.com", "data" : "mail.example.foo.com", "ttl" : 3600 }

  if [ -z $DATA ]
    then
    usage
    exit 1
  fi
  
  check_domain
	
	if [ $FOUND -eq 1 ]
	then
      
      RSPOST=`echo '{"records":[{ "priority" : '$PRIORITY',"type" : "MX", "name" : "'$NAME'", "data" : "'$DATA'", "ttl" : '$TTL' }]}'`
      
     create_record
      
    fi
}

function delete_mx() {
 
  get_domain $NAME
  
  RECORDTYPE="MX"

  delete_record
 
}

#prints words for master rsdns script output 
function words () {
	printf "Manage mail exchange (MX) records \n"
}

#Get options from the command line.
while getopts "u:a:c:d:n:D:p::hkqxw" option
do
	case $option in
		u	) RSUSER=$OPTARG ;;
		a	) RSAPIKEY=$OPTARG ;;
		c	) USERID=$OPTARG ;;
		d	) DOMAIN=$OPTARG ;;
		n	) NAME=$OPTARG ;;
		D	) DATA=$OPTARG ;;
		p	) PRIORITY=$OPTARG ;;
		t	) TTL=$OPTARG ;;
		h	) usage;exit 0 ;;
		q	) QUIET=1 ;;
		k	) UKAUTH=1 ;;
		x	) DEL=1 ;;
		w	) words;exit 0 ;;
	esac
done

#Check for enough variables, print usage if not enough.
if [ $# -lt 3 ]
	then
	usage
	exit 1
fi

if [ -z $PRIORITY ]
then
	PRIORITY="10"
fi

if [ -z $NAME ]
    then
    usage
    exit 1
fi

if [ -z $DOMAIN ]
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


if [ -n "$DEL" ]
	then
	delete_mx
else
	create_mx
fi

#done
exit 0
