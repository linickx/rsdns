#!/bin/bash
#
# rsdns-list.sh - Used to list domains and records hosted on rackspace cloud dns
#

# config file for variables.
if [ -e ~/.rsdns_config ]
then
  . ~/.rsdns_config
fi

# load up our auth & funct library
if [ -n "$RSPATH " ]
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
	printf "rscurl -u username -a apiKey -d domain\n"
	printf "\t-k Use London/UK Servers.\n"
	printf "\t-h Show this.\n"
	printf "\n"
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
	
	check_domain
	
	if [ $FOUND -eq 1 ]
	then
		
		get_records
	
		for i in `echo $RECORDS |awk -F, 'BEGIN { RS = ";" } ; {print}' `
		do
			NAME=`echo $i  | awk -F "\"*,\"*" '{print $1}'`
			RECORDID=`echo $i  | awk -F "\"*,\"*" '{print $2}'`
			TYPE=`echo $i  | awk -F "\"*,\"*" '{print $3}'`
			DATA=`echo $i  | awk -F "\"*,\"*" '{print $4}'`
			
			printf "%s - %s  - %s - %s \n" $RECORDID $TYPE $NAME $DATA
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