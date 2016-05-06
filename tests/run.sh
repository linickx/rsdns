#!/bin/bash

if [ -z $MYDOMAIN ]
then
    echo "No Test DOMAIN Set"
    exit 400
fi

if [ -z $TRAVIS_OS_NAME ]
then
	TESTDOMAIN="$MYDOMAIN"
else
    TESTDOMAIN="$TRAVIS_OS_NAME-travis-$MYDOMAIN"
fi


echo "Begining Tests for Domain: $TESTDOMAIN"

# Setup the config file
if [ ! -f ~/.rsdns_config ]; then
    echo "RSUSER=$RSUSER" > ~/.rsdns_config
    echo "RSAPIKEY=$RSAPIKEY" >> ~/.rsdns_config
    echo "RSPATH=$PWD" >> ~/.rsdns_config
    echo "UKAUTH=$UKAUTH" >> ~/.rsdns_config 
fi

# Exit Codes
## Standard
# 0 = ok
# 1 = Input/Var Missing
# 
## Custom from rsdns scipts
# 102 = API Status Exception
# 101 = API Status ERROR
# 100 = API Authentication Failure (Key)
# 98 = API Authentication Failure (Token)
# 97 = API Authentication Failure (Management Server)
# 96 = Record (to update) not found
# 95 = Failed to load auth.sh
# 94 = Failed to auth func.sh
# 93 = Domain not found
# 92 = Record not found
#
# 50 = Missing dependency
#
## Custom Exit Codes for tests
# 404 = Domain Not Found
# 400 = No Test DOMAIN Set

# Start tests

## Create a Test Domain
./rsdns domain -d $TESTDOMAIN -e travis@$TESTDOMAIN -t 600

RESULT=`rsdns list | grep $TESTDOMAIN | awk -F ' | ' '{ print $3 }'`
if [ "$RESULT" != "$TESTDOMAIN" ]
then
    echo "Domain $TESTDOMAIN not found"
    exit 404
fi

## Execute A record tests
. tests/a.sh

## list
./rsdns list -d $TESTDOMAIN

## Clean up (Has to be LAST)
. tests/delete.sh