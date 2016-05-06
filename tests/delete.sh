#!/bin/bash

# A
echo "Delete arecord.$TESTDOMAIN"
$PWD/rdns a -x -d $TESTDOMAIN -n arecord.$TESTDOMAIN

# Domain (Has to be LAST)
echo "Delete domain $TESTDOMAIN"
$PWD/rsdns domain -d $TESTDOMAIN -x