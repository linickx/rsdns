#!/bin/bash
#
# rsdns-domain.sh - Used to create/delete domains hosted on rackspace cloud dns
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
	printf "rsdns domain -u username -a apiKey -d domain -e email -t TTL\n"
	printf "\t-k Use London/UK Servers.\n"
	printf "\t-x Delete domain.\n"
	printf "\t-h Show this.\n"
	printf "\t-J Output in JSON (raw RS API data)\n"
	printf "\n"
}

function create_domain() {
# {"domains":[{"name":"example.com","ttl":86400,"emailAddress":"me@example.com"}]}

if [ -z $EMAIL ]
    then
    echo 'No email'
    usage
    exit 1
  fi

  # {"domains":[{"name":"example.com","ttl":86400,"emailAddress":"me@example.com"}]}
  RSPOST=`echo '{"domains":[{ "name" : "'$DOMAIN'", "emailAddress" : "'$EMAIL'", "ttl" : '$TTL' }]}'`
  
  RCOUTPUT="domain"
  
  RC=`curl -k -s -X POST -H X-Auth-Token:\ $TOKEN -H Content-Type:\ application/json  -H Accept:\ application/json $DNSSVR/$USERID/domains/ --data "$RSPOST" |tr -s '[:cntrl:]' "\n"`
      
  #echo $RSPOST
  
  rackspace_cloud

}

function delete_domain() {
  
  check_domain
  
  RC=`curl -k -s -X DELETE -H X-Auth-Token:\ $TOKEN -H Content-Type:\ application/json  -H Accept:\ application/json $DNSSVR/$USERID/domains/$DOMAINID|tr -s '[:cntrl:]' "\n"`
  
  rackspace_cloud
}

#prints words for master rsdns script output 
function words () {
	printf "Create & delete domains hosted by rackspace cloud DNS \n"
}

#Get options from the command line.
while getopts "u:a:c:d:e:t::hkqxwJ" option
do
	case $option in
		u	) RSUSER=$OPTARG ;;
		a	) RSAPIKEY=$OPTARG ;;
		c	) USERID=$OPTARG ;;
		d	) DOMAIN=$OPTARG ;;
		e	) EMAIL=$OPTARG ;;
		t	) TTL=$OPTARG ;;
		h	) usage;exit 0 ;;
		q	) QUIET=1 ;;
		k	) UKAUTH=1 ;;
		x	) DEL=1 ;;
		w	) words;exit 0 ;;
		J	) RSJSON=1 ;;
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
	delete_domain
else
	create_domain
fi

#done
exit 0
