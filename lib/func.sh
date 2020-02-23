#!/bin/bash
#
# Functions used in >1 tools
#
RSDNS_VERSION="4.2"

#gets the domains associated with an account.
function get_domains() {
    
    if [ -z "$RSLIMIT" ]
    then
        # Set limit for pagination
        RSLIMIT=99
    fi
    
    #  Curl response in JSON
    jDOMAINS=`curl -A "rsdns/$RSDNS_VERSION (https://github.com/linickx/rsdns)" -k -s -X GET -H X-Auth-Token:\ $TOKEN $DNSSVR/$USERID/domains?limit=$RSLIMIT`
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
                jDOMAINSp=`curl -A "rsdns/$RSDNS_VERSION (https://github.com/linickx/rsdns)" -k -s -X GET -H X-Auth-Token:\ $TOKEN $NEXTURL`
                #echo $jDOMAINSp
                jDOMAINS+=$jDOMAINSp
            elif [ "$PAGSTATUS0" == "previous" ]; then
                NEXTURL=`echo $jDOMAINSp | jq -r .links[1].href`
                jDOMAINSp=`curl -A "rsdns/$RSDNS_VERSION (https://github.com/linickx/rsdns)" -k -s -X GET -H X-Auth-Token:\ $TOKEN $NEXTURL`
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
    jRECORDS=`curl -A "rsdns/$RSDNS_VERSION (https://github.com/linickx/rsdns)" -k -s -X GET -H X-Auth-Token:\ $TOKEN $DNSSVR/$USERID/domains/$DOMAINID/records?limit=$RSLIMIT`
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
                jRECORDSp=`curl -A "rsdns/$RSDNS_VERSION (https://github.com/linickx/rsdns)" -k -s -X GET -H X-Auth-Token:\ $TOKEN $NEXTURL`
                jRECORDS+=$jRECORDSp
            elif [ "$PAGSTATUS0" == "previous" ]; then
                NEXTURL=`echo $jRECORDSp | jq -r .links[1].href`
                jRECORDSp=`curl -A "rsdns/$RSDNS_VERSION (https://github.com/linickx/rsdns)" -k -s -X GET -H X-Auth-Token:\ $TOKEN $NEXTURL`
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
        exit 93
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
            iNAME=`echo $i  | awk -F "|" '{print $2}'`
            iRECORDID=`echo $i  | awk -F "|" '{print $1}'`
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
        exit 92
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
  
  if [ -z $RECORDID ]
  then
    get_recordid
  fi

  RC=`curl -A "rsdns/$RSDNS_VERSION (https://github.com/linickx/rsdns)" -k -s -X DELETE -H X-Auth-Token:\ $TOKEN -H Content-Type:\ application/json  -H Accept:\ application/json $DNSSVR/$USERID/domains/$DOMAINID/records/$RECORDID|tr -s '[:cntrl:]' "\n"`
  
  rackspace_cloud
  
}

function create_record() {

    RC=`curl -A "rsdns/$RSDNS_VERSION (https://github.com/linickx/rsdns)" -k -s -X POST -H X-Auth-Token:\ $TOKEN -H Content-Type:\ application/json  -H Accept:\ application/json $DNSSVR/$USERID/domains/$DOMAINID/records --data "$RSPOST" |tr -s '[:cntrl:]' "\n"`
      
    #echo $RSPOST

    rackspace_cloud
}

function rackspace_cloud() {
          
      if [[ $RSJSON -eq 1 ]]; then
        echo $RC
        exit 0
      fi
      
      if [[ $QUIET -eq 0 ]]; then
        #echo $RC | jq .
        
        RC_STATUS=`echo $RC | jq .status | tr -d '"'`
        echo "Job status is: $RC_STATUS"
        
        RC_CALLBACK=`echo $RC | jq .callbackUrl | tr -d '"'`
        
        if [ "$RC_STATUS" == "RUNNING" ]
        then
            while true; do

                RC=`curl -A "rsdns/$RSDNS_VERSION (https://github.com/linickx/rsdns)" -k -s -X GET -H X-Auth-Token:\ $TOKEN $RC_CALLBACK?showDetails=true|tr -s '[:cntrl:]' "\n"`
                
                RC_STATUS=`echo $RC | jq .status | tr -d '"'`
                echo "Job status is: $RC_STATUS"
                echo 
                
                if [ "$RC_STATUS" == "COMPLETED" ]
                then
                    #echo $RC | jq .

                    if [[ $DEL -eq 1 ]]
                    then
                        if [ -n "$RECORDID" ]
                        then
                            echo "Record $RECORDID deleted."
                        else 
                            echo "Domain $DOMAINID deleted."
                        fi
                        echo
                        exit
                    elif [[ $UPDATE -eq 1 ]]; then
                        if [ -n "$RECORDID" ]
                        then
                            echo "Record $RECORDID updated."
                        else 
                            echo "Done."
                        fi
                        echo
                        exit
                    else
                        if [ "$RCOUTPUT" == "domain" ]
                        then                            
                            echo $RC | jq -r '(.response.domains[] | " ID: \(.id) | NAME: \(.name) | Account: \(.accountId) | TTL: \(.ttl) | EMAIL: \(.emailAddress) | CREATED: \(.created) | UPDATED: \(.updated)")' | tr -s '|' "\n"
                        elif [[ "$RCOUTPUT" == "mx" ]]; then
                            echo $RC | jq -r '(.response.records[] | " ID: \(.id) | TYPE: \(.type) | NAME: \(.name) | DATA: \(.data) | PRIORITY: \(.priority) | TTL: \(.ttl) | CREATED: \(.created) | UPDATED: \(.updated)")' | tr -s '|' "\n"
                        else
                            echo $RC | jq -r '(.response.records[] | " ID: \(.id) | TYPE: \(.type) | NAME: \(.name) | DATA: \(.data) | TTL: \(.ttl) | CREATED: \(.created) | UPDATED: \(.updated)")' | tr -s '|' "\n"
                        fi
                    fi
                    
                    echo
                    break
                elif [ "$RC_STATUS" == "ERROR" ]; then
                    echo $RC | jq .
                    exit 101
                    break
                else
                    echo "Sleeping...."
                    sleep 1
                fi
            done
        else
             echo $RC | jq .
             exit 102
        fi
        
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
    type $1 >/dev/null 2>&1 || { echo >&2 "I require $1 but it's not installed.  Aborting."; exit 50; }
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
