#!/bin/bash

# A
echo "Delete arecord.$TESTDOMAIN"
./rdns a -x -d $TESTDOMAIN -n arecord.$TESTDOMAIN

# Domain (Has to be LAST)
echo "Delete domain $TESTDOMAIN"
./rsdns domain -d $TESTDOMAIN -x