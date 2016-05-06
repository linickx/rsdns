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

# Start tests
./rsdns version

## Create a Test Domain
./rsdns domain -d $TESTDOMAIN -e travis@$TESTDOMAIN -t 600

RESULT=`rsdns list | grep $TESTDOMAIN | awk -F ' | ' '{ print $3 }'`
if [ "$RESULT" != "$TESTDOMAIN" ]
then
    echo "Domain $TESTDOMAIN not found"
    exit 404
fi

## A record tests
. tests/a.sh
## AAAA record tests
. tests/aaaa.sh
## CNAME record tests
. tests/cn.sh
## MX record tests
. tests/mx.sh
## SRV record tests
. tests/srv.sh
## TXT record tests
. tests/txt.sh

## NS Update
./rdns ns -d $TESTDOMAIN -s dns1.stabletransit.com -S ns1.$TESTDOMAIN

## Export
./rsdns export -d $TESTDOMAIN

## list
./rsdns list -d $TESTDOMAIN

## Dynamic Clients
./rsdns-dc.sh -n arecord.$TESTDOMAIN
./rsdns-dc6.sh -n aaaarecord.$TESTDOMAIN

## Delete by ID
# 

## Clean up (Has to be LAST)
. tests/delete.sh