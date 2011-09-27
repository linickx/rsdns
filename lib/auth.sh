#!/bin/bash
#
# Authenication Functions
#
# Pated from https://github.com/jsquared/rscurl
#

#Authenticates to the Rackspace Service and sets up the Authentication Token and Managment server
#REQUIRES: 1=AuthUser 2=API_Key
function get_auth () {
	
	if [ -z $RSUSER ]
	then
		usage
		exit 1
	fi
	
	if [ -z $RSAPIKEY ]
	then
		usage
		exit 1
	fi

	
	if [[ $UKAUTH -eq 1 ]]; then
		AUTHSVR="https://lon.auth.api.rackspacecloud.com/v1.0"
		DNSSVR="https://lon.dns.api.rackspacecloud.com/v1.0"
	else
		AUTHSVR="https://auth.api.rackspacecloud.com/v1.0"
		DNSSVR="https://dns.api.rackspacecloud.com/v1.0"
	fi
	
	AUTH=`curl -s -X GET -D - -H X-Auth-User:\ $RSUSER -H X-Auth-Key:\ $RSAPIKEY $AUTHSVR|tr -s [:cntrl:] "\n" \
		|awk '{ if ($1 == "HTTP/1.1") printf "%s,", $2 ; if ($1 == "X-Auth-Token:") printf "%s,", $2 ; if ($1 == "X-Server-Management-Url:") printf "%s,", $2 ;}' `
	
		
	EC=`echo $AUTH|awk -F, '{print $1}'`
	if [[ $EC == "204" ]]; then
		TOKEN=`echo $AUTH|awk -F, '{print $2}'`
		MGMTSVR=`echo $AUTH|awk -F, '{print $3}'`
		USERID=`echo $MGMTSVR | awk -F "/" '{print $5}'`
	else
		if [[ $QUIET -eq 1 ]]; then
			exit $EC
		fi
		echo "Authentication Failed ($EC)"
		exit $EC
	fi
}

function http_code_eval () {
	if [ $QUIET -eq 1 ]
		then
		case $1 in
			202 ) exit 0 ;;
			204	) exit 0 ;;
			* ) exit $1 ;;
		esac
	else
		case $1 in
			202	) echo "Action request successful." ; exit 0;;
			204	) echo "Action request successful." ; exit 0;;
			401 ) echo "Request Unauthorized.  Is your username and api key correct?"; exit $1;;
			404	) echo "Server ID not found."; exit $1;;
			409	) echo "Server is currently being built, please wait and retry."; exit $1;;
			413	) echo "API Request limit reached, please wait and retry."; exit $1;;
			422	) echo "Unprocessable Entity, cannot resize while a backup is in progress."; exit $1;;
			503	) echo "Rackspace Cloud service unavailable, please check and then retry."; exit $1;;
			*	) echo "An unknown error has occured. ($RC)"; exit 99;;
		esac
	fi
}
# Variable Defaults
if [ -z $QUIET ]
then
  QUIET=0
fi

if [ -z $UKAUTH ]
then
  UKAUTH=0
fi