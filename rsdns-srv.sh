#!/bin/bash
#
# rsdns-srv.sh - Used to create/delete SRV records hosted on rackspace cloud dns
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
    printf "rsdns srv -u username -a apiKey -d domain -n name -T targethost.domain.com -p priority -P port -W weight -t TTL\n"
    printf "\t-p Priority (0 through 65535). Default 10\n"
    printf "\t-T Target\n"
    printf "\t-W Weight. Default 1\n"
    printf "\t-P Port\n"
    printf "\t-k Use London/UK Servers.\n"
    printf "\t-x Delete record.\n"
    printf "\t-h Show this.\n"
    printf "\t-J Output in JSON (raw RS API data)\n"
    printf "\n"
}


function create_srv () {
#{ "id" : "SRV-123", "type" : "SRV", "name" : "_tcp._sip.example.foo.com", "priority" : 30, "data" : "1 3443 sip.foo.com", "ttl" : 86400 }


  check_domain

    if [ $FOUND -eq 1 ]
    then

      DATA="$WEIGHT $PORT $TARGET"
      # echo $DATA
      RSPOST=`echo '{"records":[{ "type" : "SRV", "name" : "'$NAME'", "priority" : "'$PRIORITY'", "data" : "'$DATA'", "ttl" : '$TTL' }]}'`

     create_record

    fi
}

function delete_srv() {

  RECORDTYPE="SRV"

  delete_record

}

#prints words for master rsdns script output
function words () {
    printf "Manage service (SRV) records \n"
}

#Get options from the command line.
while getopts "u:a:c:d:n:T:t:p:P:W::hkqxwJ" option
do
    case $option in
        u    ) RSUSER=$OPTARG ;;
        a    ) RSAPIKEY=$OPTARG ;;
        c    ) USERID=$OPTARG ;;
        d    ) DOMAIN=$OPTARG ;;
        n    ) NAME=$OPTARG ;;
        T    ) TARGET=$OPTARG ;;
        p    ) PRIORITY=$OPTARG ;;
        P    ) PORT=$OPTARG ;;
        W    ) WEIGHT=$OPTARG ;;
        t    ) TTL=$OPTARG ;;
        h    ) usage;exit 0 ;;
        q    ) QUIET=1 ;;
        k    ) UKAUTH=1 ;;
        x    ) DEL=1 ;;
        w    ) words;exit 0 ;;
        J    ) RSJSON=1 ;;
    esac
done

#Check for enough variables, print usage if not enough.
if [ $# -lt 3 ]
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

if [ -z $PRIORITY ]
then
    PRIORITY="10"
fi

if [ -z $WEIGHT ]
then
    WEIGHT="1"
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
if test -z "$MGMTSVR"
    then
    if [[ $QUIET -eq 0 ]]; then
        echo Management Server does not exist.
    fi
    exit 97
fi


if [ -n "$DEL" ]
    then
    delete_srv
else
    if [ -z $PORT ]
        then
        usage
        exit 1
    fi
    if [ -z $TARGET ]
        then
        usage
        exit 1
    fi
    create_srv
fi

#done
exit 0
