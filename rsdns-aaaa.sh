#!/bin/bash
#
# rsdns-aaaa.sh - Used to create/delete AAAA records hosted on rackspace cloud dns
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
	printf "rsdns aaaa -u username -a apiKey -n name -i IP -t TTL\n"
	printf "\t-d Set the domain name manually"
	printf "\t-k Use London/UK Servers.\n"
	printf "\t-x Delete record.\n"
	printf "\t-U Update existing record.\n"
	printf "\t-h Show this.\n"
	printf "\n"
}


function create_aaaa () {
# { "id" : "AAAA-123", "type" : "AAAA", "name" : "example.foo.com", "data" : "4321:0:1:2:3:4:567:89ab", "ttl" : 3600 }

  if [ -z $IP ]
    then
    usage
    exit 1
  fi

 	get_domain $NAME
  

 	check_domain
	
	if [ $FOUND -eq 1 ]
	then
      
      #RSPOST='{"records":[{ "type" : "AAAA", "name" : "b.test.linickx.co.uk", "data" : "4321:0:1:2:3:4:567:89ab", "ttl" : 86400 }]}'
      RSPOST=`echo '{"records":[{ "type" : "AAAA", "name" : "'$NAME'", "data" : "'$IP'", "ttl" : '$TTL' }]}'`
      
      create_record
  
    fi
}

function update_aaaa() {

  if [ -z $IP ]
    then
    usage
    exit 1
  fi

  get_domain $NAME
  
  RECORDTYPE="AAAA"
  
  get_recordid
  
      RSPOST=`echo '{ "name" : "'$NAME'", "data" : "'$IP'", "ttl" : '$TTL' }'`
  
      RC=`curl -k -s -X PUT -H X-Auth-Token:\ $TOKEN -H Content-Type:\ application/json  -H Accept:\ application/json $DNSSVR/$USERID/domains/$DOMAINID/records/$RECORDID --data "$RSPOST" |tr -s [:cntrl:] "\n"`
      
      
      if [[ $QUIET -eq 0 ]]; then
		echo $RC
      fi


}

function delete_aaaa () {

  get_domain $NAME
  
  RECORDTYPE="AAAA"

  delete_record

}

#prints words for master rsdns script output 
function words () {
	printf "Manage AAAA records, host records for IPv6 \n"
}

#Get options from the command line.
while getopts "u:a:c:d:n:i:t::hkqxUw" option
do
	case $option in
		u	) RSUSER=$OPTARG ;;
		a	) RSAPIKEY=$OPTARG ;;
		c	) USERID=$OPTARG ;;
		n	) NAME=$OPTARG ;;
		d	) DOMAIN=$OPTARG ;;
		i	) IP=$OPTARG ;;
		t	) TTL=$OPTARG ;;
		h	) usage;exit 0 ;;
		q	) QUIET=1 ;;
		k	) UKAUTH=1 ;;
		x	) DEL=1 ;;
		U	) UPDATE=1 ;;
		w	) words;exit 0 ;;
	esac
done

#Check for enough variables, print usage if not enough.
if [ $# -lt 2 ]
	then
	usage
	exit 1
fi

if [ -z $NAME ]
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

if [ -n "$UPDATE" ]
  then
  update_aaaa
  exit 1
fi

if [ -n "$DEL" ]
	then
	delete_aaaa
else
	create_aaaa
fi

#done
exit 0
