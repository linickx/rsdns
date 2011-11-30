#!/bin/bash
#
# rsdns-ns.sh - Used to update NS records for domains hosted on rackspace cloud dns
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
	printf "rscurl -u username -a apiKey -d domain -s old nameserver -S new nameserver \n"
	printf "\t-k Use London/UK Servers.\n"
	printf "\t-c clientID (cloud sites only)\n"
	printf "\t-h Show this.\n"
	printf "\n"
}

function update_ns() {

	check_domain

	RECORDTYPE="NS"

	get_records
   
	FOUND=0
   
	
	for i in `echo $RECORDS | awk -F, 'BEGIN { RS = ";" } ; {print}' `
	do
		i=`echo $i | grep $RECORDTYPE`
	
		iNAME=`echo $i  | awk -F "\"*,\"*" '{print $4}'`

		iRECORDID=`echo $i  | awk -F "\"*,\"*" '{print $2}'`
		
		if [ "$iNAME" == "$OLDNS" ]
		then
			FOUND=1
			RECORDID=$iRECORDID
		fi
	done
	
	if [ $FOUND -eq 0 ]
	then
		printf "\n" 
		printf "record for %s not found." $OLDNS
		printf "\n"
		exit 98
	fi

	# { "id" : "NS-123", "type" : "NS" "name" : "example.foo.com", "data" : "ns1.foo.com", "ttl" : 54000 }
  
    RSPOST=`echo '{ "name" : "'$DOMAIN'", "data" : "'$NEWNS'", "ttl" : '$TTL' }'`
  
      RC=`curl -k -s -X PUT -H X-Auth-Token:\ $TOKEN -H Content-Type:\ application/json  -H Accept:\ application/json $DNSSVR/$USERID/domains/$DOMAINID/records/$RECORDID --data "$RSPOST" |tr -s [:cntrl:] "\n"`
      
      
      if [[ $QUIET -eq 0 ]]; then
		echo $RC
      fi


}

#Get options from the command line.
while getopts "u:a:c:d:s:S:t::hkqx" option
do
	case $option in
		u	) RSUSER=$OPTARG ;;
		a	) RSAPIKEY=$OPTARG ;;
		c	) USERID=$OPTARG ;;
		d	) DOMAIN=$OPTARG ;;
		s	) OLDNS=$OPTARG ;;
		S	) NEWNS=$OPTARG ;;
		t	) TTL=$OPTARG ;;
		h	) usage;exit 0 ;;
		q	) QUIET=1 ;;
		k	) UKAUTH=1 ;;
		x	) DEL=1 ;;
	esac
done

#Check for enough variables, print usage if not enough.
if [ $# -lt 3 ]
	then
	usage
	exit 1
fi

if [ -z $DOMAIN ]
    then
    usage
    exit 1
fi

if [ -z $OLDNS ]
    then
    usage
    exit 1
fi

if [ -z $NEWNS ]
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

	update_ns


#done
exit 0