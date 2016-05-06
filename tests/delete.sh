#!/bin/bash

# A
echo "Delete arecord.$TESTDOMAIN"
$PWD/rdns a -x -d $TESTDOMAIN -n arecord.$TESTDOMAIN
# AAAA
echo "Delete aaaarecord.$TESTDOMAIN"
$PWD/rdns aaaa -x -d $TESTDOMAIN -n aaaarecord.$TESTDOMAIN
# CNAME
echo "Delete cn.$TESTDOMAIN"
$PWD/rdns cn -x -d $TESTDOMAIN -n cn.$TESTDOMAIN
# MX
echo "Delete MX from $TESTDOMAIN"
$PWD/rdns mx -x -d $TESTDOMAIN -n $TESTDOMAIN
# SRV
echo "Delete SRV _tcp._sip.$TESTDOMAIN"
$PWD/rdns srv -x -d $TESTDOMAIN -n _tcp._sip.$TESTDOMAIN

# Domain (Has to be LAST)
echo "Delete domain $TESTDOMAIN"
$PWD/rsdns domain -d $TESTDOMAIN -x