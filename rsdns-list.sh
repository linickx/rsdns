#!/bin/bash
#
# rsdlist.sh - Used to list domains and records hosted on rackspace cloud dns
#

# load up our auth library
. lib/auth.sh

#prints out the usage information on error or request.
function usage () {
	printf "\n"
	printf "rscurl -u username -a apiKey -d domain \n"
	printf "\t-h Show this.\n"
	printf "\n"
}

#gets the domains associated with an account.
function get_domains() {
	DOMAINS=`curl -s -X GET -H X-Auth-Token:\ $TOKEN $DNSSVR/$USERID/domains|tr -s [:cntrl:] "\n" |sed -e 's/{"domains":\[{//' -e 's/}\]}//' -e 's/},{/;/g' -e 's/"name"://g' -e 's/"id"://g' -e 's/"accountId"://g' -e 's/"updated"://g' -e 's/"created"://g' -e 's/"totalEntries"://g'`

}

#prints out the domains associated with an account.
function print_domains () {
	
	get_domains
	
	
	for i in `echo $DOMAINS |awk -F, 'BEGIN { RS = ";" } ; {print}' `
	do
		
		DOMAINID=`echo $i  | awk -F "\"*,\"*" '{print $2}'`
		
		DOMAINNAME=`echo $i  | awk -F "\"*,\"*" '{print $1}'`
		DOMAINNAME=`echo ${DOMAINNAME:1}`
		
		printf " %s  - %s \n" $DOMAINID $DOMAINNAME
	done
	
}

#prints out the records for a given domain.
function print_records() {
	
	get_domains
	
	FOUND=0
	
	for i in `echo $DOMAINS |awk -F, 'BEGIN { RS = ";" } ; {print}' `
	do
		
		iDOMAINID=`echo $i  | awk -F "\"*,\"*" '{print $2}'`
		
		iDOMAINNAME=`echo $i  | awk -F "\"*,\"*" '{print $1}'`
		iDOMAINNAME=`echo ${iDOMAINNAME:1}`
		
		
		if [ "$iDOMAINNAME" == "$DOMAIN" ]
		then
			FOUND=1
			DOMAINID=$iDOMAINID
			DOMAINNAME=$iDOMAINNAME
		fi
	done
	
	if [ $FOUND -eq 0 ]
	then
		printf "\n" 
		printf "Domain %s not found." $DOMAIN
		printf "\n"
		exit 98
	fi

	if [ $FOUND -eq 1 ]
	then
		
		RECORDS=`curl -s -X GET -H X-Auth-Token:\ $TOKEN $DNSSVR/$USERID/domains/$DOMAINID/records|tr -s [:cntrl:] "\n" | sed -e 's/{"records":\[{//' -e 's/}\]}//' -e 's/},{/;/g' -e 's/"name"://g' -e 's/"id"://g' -e 's/"type"://g' -e 's/"data"://g' -e 's/"updated"://g' -e 's/"created"://g' -e 's/"totalEntries"://g'`
	
		
		for i in `echo $RECORDS |awk -F, 'BEGIN { RS = ";" } ; {print}' `
		do
			NAME=`echo $i  | awk -F "\"*,\"*" '{print $1}'`
			TYPE=`echo $i  | awk -F "\"*,\"*" '{print $3}'`
			DATA=`echo $i  | awk -F "\"*,\"*" '{print $4}'`
			
			printf " %s  - %s - %s \n" $TYPE $NAME $DATA
		done
	
	fi
	
	
}

#Get options from the command line.
while getopts "u:a:d::hkq" option
do
	case $option in
		u	) RSUSER=$OPTARG ;;
		a	) RSAPIKEY=$OPTARG ;;
		d	) DOMAIN=$OPTARG ;;
		h	) usage;exit 0 ;;
		q	) QUIET=1 ;;
		k	) UKAUTH=1 ;;
	esac
done

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

#if a domain is given, print records, else print domaints
if [ -z "$DOMAIN" ]
	then
	print_domains 
else
	print_records
fi

#done
exit 0