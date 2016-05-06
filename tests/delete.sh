#!/bin/bash

# A
echo "Delete arecord.$TESTDOMAIN"
$PWD/rdns a -x -d $TESTDOMAIN -n arecord.$TESTDOMAIN
# AAAA
echo "Delete aaaarecord.$TESTDOMAIN"
$PWD/rdns a -x -d $TESTDOMAIN -n aaaarecord.$TESTDOMAIN
# CNAME
echo "Delete cn.$TESTDOMAIN"
$PWD/rdns cn -x -d $TESTDOMAIN -n cn.$TESTDOMAIN

# Domain (Has to be LAST)
echo "Delete domain $TESTDOMAIN"
$PWD/rsdns domain -d $TESTDOMAIN -x