#!/bin/bash
#
# Functions used in >1 tools
#

#gets the domains associated with an account.
function get_domains() {
	DOMAINS=`curl -k -s -X GET -H X-Auth-Token:\ $TOKEN $DNSSVR/$USERID/domains|tr -s [:cntrl:] "\n" |sed -e 's/{"domains":\[{//' -e 's/}\]}//' -e 's/},{/;/g' -e 's/"name"://g' -e 's/"id"://g' -e 's/"accountId"://g' -e 's/"updated"://g' -e 's/"created"://g' -e 's/"totalEntries"://g'`

}

function get_records() {
    RECORDS=`curl -k -s -X GET -H X-Auth-Token:\ $TOKEN $DNSSVR/$USERID/domains/$DOMAINID/records|tr -s [:cntrl:] "\n"`
    #echo $RECORDS
    RECORDS=`echo $RECORDS | sed -e 's/{"records":\[{//' -e 's/}\]}//' -e 's/},{/;/g' -e 's/"name"://g' -e 's/"id"://g' -e 's/"type"://g' -e 's/"data"://g' -e 's/"updated"://g' -e 's/"created"://g' -e 's/"totalEntries"://g'`
}

function check_domain() {

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


}

function get_recordid() {

   check_domain
   
   get_records
   
   FOUND=0
   
	
	for i in `echo $RECORDS |awk -F, 'BEGIN { RS = ";" } ; {print}' `
	do
		i=`echo $i | grep $RECORDTYPE`
		iNAME=`echo $i  | awk -F "\"*,\"*" '{print $1}'`
		iNAME=`echo ${iNAME:1}`
		
		iRECORDID=`echo $i  | awk -F "\"*,\"*" '{print $2}'`
		
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
  
  RC=`curl -k -s -X DELETE -D - -H X-Auth-Token:\ $TOKEN -H Content-Type:\ application/json  -H Accept:\ application/json $DNSSVR/$USERID/domains/$DOMAINID/records/$RECORDID|tr -s [:cntrl:] "\n"`
  
  if [[ $QUIET -eq 0 ]]; then
    echo $RC
  fi
  
}

function create_record() {

    RC=`curl -k -s -X POST -H X-Auth-Token:\ $TOKEN -H Content-Type:\ application/json  -H Accept:\ application/json $DNSSVR/$USERID/domains/$DOMAINID/records --data "$RSPOST" |tr -s [:cntrl:] "\n"`
      
      #echo $RSPOST
      
      if [[ $QUIET -eq 0 ]]; then
		echo $RC
      fi

}

if [ -z $TTL ]
then
	TTL="86400"
fi