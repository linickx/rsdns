#!/bin/bash

TESTDOMAIN="$TRAVIS_OS_NAME-travis-rsdns.linickx.co.uk"

echo $TESTDOMAIN

echo "NBTESTVAR=$NBTESTVAR" > ~/.rsdns_config
cat ~/.rsdns_config

# Setup the config file
echo "RSUSER=$RSUSER" > ~/.rsdns_config
echo "RSAPIKEY=$RSAPIKEY" >> ~/.rsdns_config
echo "RSPATH=$RSPATH" >> ~/.rsdns_config
echo "UKAUTH=$UKAUTH" >> ~/.rsdns_config 

# Start tests

. tests/a.sh