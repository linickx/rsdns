#!/bin/bash
#
# Functions used in >1 tools
#
RSDNS_VERSION="3.1"

#gets the domains associated with an account.
function get_domains() {
	
	if [ -z "$RSLIMIT" ]
	then
		# Set limit for pagination
		RSLIMIT=99
	fi
	
	#  Curl response in JSON
	jDOMAINS=`curl -k -s -X GET -H X-Auth-Token:\ $TOKEN $DNSSVR/$USERID/domains?limit=$RSLIMIT`
	PAGSTATUS0=`echo $jDOMAINS | jq -r .links[0].rel` &>/dev/null
	
	if [ "$PAGSTATUS0" == "next" ]
	then
		jDOMAINSp=$jDOMAINS

		echo -n "Downloading Domains."
		while true; do
			PAGSTATUS0=`echo $jDOMAINSp | jq -r .links[0].rel` &>/dev/null
			
			echo -n "."
			
			if [ "$PAGSTATUS0" == "next" ]
			then
				NEXTURL=`echo $jDOMAINSp | jq -r .links[].href`
				jDOMAINSp=`curl -k -s -X GET -H X-Auth-Token:\ $TOKEN $NEXTURL`
				#echo $jDOMAINSp
				jDOMAINS+=$jDOMAINSp
			elif [ "$PAGSTATUS0" == "previous" ]; then
				NEXTURL=`echo $jDOMAINSp | jq -r .links[1].href`
				jDOMAINSp=`curl -k -s -X GET -H X-Auth-Token:\ $TOKEN $NEXTURL`
				#echo $jDOMAINSp
				jDOMAINS+=$jDOMAINSp
			else
				break
			fi
		done
		echo
	fi

	# Legacy variable/response for backward compatability
	DOMAINS=`echo $jDOMAINS |tr -s '[:cntrl:]' "\n" |sed -e 's/{"domains":\[{//' -e 's/}\]}//' -e 's/},{/;/g' -e 's/"name"://g' -e 's/"id"://g' -e 's/"accountId"://g' -e 's/"updated"://g' -e 's/"created"://g' -e 's/"totalEntries"://g'`	
}

function get_records() {
    jRECORDS=`curl -k -s -X GET -H X-Auth-Token:\ $TOKEN $DNSSVR/$USERID/domains/$DOMAINID/records?limit=$RSLIMIT`
	PAGSTATUS0=`echo $jRECORDS | jq -r .links[0].rel` &>/dev/null
	
	if [ "$PAGSTATUS0" == "next" ]
	then
		jRECORDSp=$jRECORDS

		echo -n "Downloading Records."
		while true; do
			PAGSTATUS0=`echo $jRECORDSp | jq -r .links[0].rel` &>/dev/null
			echo -n "."
			
			if [ "$PAGSTATUS0" == "next" ]
			then
				NEXTURL=`echo $jRECORDSp | jq -r .links[].href`
				jRECORDSp=`curl -k -s -X GET -H X-Auth-Token:\ $TOKEN $NEXTURL`
				jRECORDS+=$jRECORDSp
			elif [ "$PAGSTATUS0" == "previous" ]; then
				NEXTURL=`echo $jRECORDSp | jq -r .links[1].href`
				jRECORDSp=`curl -k -s -X GET -H X-Auth-Token:\ $TOKEN $NEXTURL`
				jRECORDS+=$jRECORDSp
			else
				break
			fi
		done
		echo
	fi
	#echo $jRECORDS | jq .

    RECORDS=`echo $jRECORDS |tr -s '[:cntrl:]' "\n"| sed -e 's/{"records":\[{//' -e 's/}\]}//' -e 's/},{/;/g' -e 's/"name"://g' -e 's/"id"://g' -e 's/"type"://g' -e 's/"data"://g' -e 's/"updated"://g' -e 's/"created"://g' -e 's/"totalEntries"://g'`
}

function check_domain() {

    get_domains

    FOUND=0
	
	for i in `echo $jDOMAINS | jq -r '.domains[] | "\(.id)|\(.name)"'`
	do
		
		iDOMAINID=`echo $i  | awk -F "|" '{print $1}'`
		iDOMAINNAME=`echo $i  | awk -F "|" '{print $2}'`
		#echo "$iDOMAINID - $iDOMAINNAME"

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
}

function get_recordid() {

   check_domain
   
   get_records
   
   FOUND=0

	for i in `echo $RECORDS | awk -F, 'BEGIN { RS = ";" } { gsub(/\"/,"") ; print $1 "|" $2 "|" $3 "|" $4 }'`
	do
	
		if [ "$RECORDTYPE" == "MX" ]
		then
			iTYPE=`echo $i  | awk -F "|" '{print $4}'`
		else
			iTYPE=`echo $i  | awk -F "|" '{print $3}'`
		fi

		if [ "$iTYPE" == "$RECORDTYPE" ]
		then
			iNAME=`echo $i  | awk -F "|" '{print $1}'`
			iRECORDID=`echo $i  | awk -F "|" '{print $2}'`
		fi

		if [ "$iNAME" == "$NAME" ]
		then
			FOUND=1
			RECORDID=$iRECORDID
		fi
	done

	if [ $FOUND -eq 0 ]
	then
		printf "\n" 
		printf "record for %s not found." $NAME
		printf "\n"
		exit 98
	fi

}

function get_domain() {

  if [ -z $DOMAIN ]
  	then
	  HOST=`echo $1 | awk -F "." '{print $1}'`
	  HOSTlen=${#HOST}
	  
	  HOSTlen=$(($HOSTlen + 1))

	  DOMAIN=${1:($HOSTlen)}
  fi
}

function delete_record() {
  
  get_recordid
  
  RC=`curl -k -s -X DELETE -D - -H X-Auth-Token:\ $TOKEN -H Content-Type:\ application/json  -H Accept:\ application/json $DNSSVR/$USERID/domains/$DOMAINID/records/$RECORDID|tr -s '[:cntrl:]' "\n"`
  
  if [[ $QUIET -eq 0 ]]; then
    echo $RC
  fi
  
}

function create_record() {

    RC=`curl -k -s -X POST -H X-Auth-Token:\ $TOKEN -H Content-Type:\ application/json  -H Accept:\ application/json $DNSSVR/$USERID/domains/$DOMAINID/records --data "$RSPOST" |tr -s '[:cntrl:]' "\n"`
      
      #echo $RSPOST
      
      if [[ $QUIET -eq 0 ]]; then
		echo $RC
      fi

}

#prints out the domains associated with an account.
function print_domains () {

	get_domains

	echo "ID      | Domain"
	echo $jDOMAINS | jq -r '.domains[] | "\(.id) | \(.name)"'

}

function check_dep() {
	# http://stackoverflow.com/questions/592620/how-to-check-if-a-program-exists-from-a-bash-script
	type $1 >/dev/null 2>&1 || { echo >&2 "I require $1 but it's not installed.  Aborting."; exit 1; }
}

if [ -z $TTL ]
then
	TTL="86400"
fi

# Check for dependencies
check_dep "curl"
check_dep "awk"
check_dep "sed"
check_dep "jq"
