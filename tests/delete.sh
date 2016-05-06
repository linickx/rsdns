#!/bin/bash

# A
echo "Delete arecord.$TESTDOMAIN"
$PWD/rsdns a -x -d $TESTDOMAIN -n arecord.$TESTDOMAIN
# AAAA
echo "Delete aaaarecord.$TESTDOMAIN"
$PWD/rsdns aaaa -x -d $TESTDOMAIN -n aaaarecord.$TESTDOMAIN
# CNAME
echo "Delete cn.$TESTDOMAIN"
$PWD/rsdns cn -x -d $TESTDOMAIN -n cn.$TESTDOMAIN
# MX
echo "Delete MX from $TESTDOMAIN"
$PWD/rsdns mx -x -d $TESTDOMAIN -n $TESTDOMAIN
# SRV
echo "Delete SRV _tcp._sip.$TESTDOMAIN"
$PWD/rsdns srv -x -d $TESTDOMAIN -n _tcp._sip.$TESTDOMAIN
# TXT
echo "Delete TXT from $TESTDOMAIN"
$PWD/rsdns txt -x -d $TESTDOMAIN -n $TESTDOMAIN

# Domain (Has to be LAST)
echo "Delete domain $TESTDOMAIN"
$PWD/rsdns domain -d $TESTDOMAIN -x