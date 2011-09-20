#!/bin/bash
#
# rsdns-txt.sh - Used to create/delete TXT records hosted on rackspace cloud dns
#

# load up our auth library
. lib/auth.sh

# load up our function library
. lib/func.sh

#prints out the usage information on error or request.
function usage () {
	printf "\n"
	printf "rscurl -u username -a apiKey -d domain -n name -D data -t TTL\n"
	printf "\t-k Use London/UK Servers.\n"
	printf "\t-x Delete record.\n"
	printf "\t-h Show this.\n"
	printf "\n"
}


function create_txt () {
# { "id" : "TXT-123", "type" : "TXT", "name" : "example.foo.com", "data" : "Some example text", "ttl" : 3600 }


  check_domain
	
	if [ $FOUND -eq 1 ]
	then
      
      RSPOST=`echo '{"records":[{ "type" : "TXT", "name" : "'$NAME'", "data" : "'$DATA'", "ttl" : '$TTL' }]}'`
      
     create_record
      
    fi
}

function delete_txt() {
 
  RECORDTYPE="TXT"

  delete_record
  
}

#Get options from the command line.
while getopts "u:a:d:n:D:t::hkqx" option
do
	case $option in
		u	) RSUSER=$OPTARG ;;
		a	) RSAPIKEY=$OPTARG ;;
		d	) DOMAIN=$OPTARG ;;
		n	) NAME=$OPTARG ;;
		D	) DATA=$OPTARG ;;
		t	) TTL=$OPTARG ;;
		h	) usage;exit 0 ;;
		q	) QUIET=1 ;;
		k	) UKAUTH=1 ;;
		x	) DEL=1 ;;
	esac
done

#Check for enough variables, print usage if not enough.
if [ $# -lt 5 ]
	then
	usage
	exit 1
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
	delete_txt
else
	create_txt
fi

#done
exit 0