# !/bin/bash

echo "Create SRV record _tcp._sip.$TESTDOMAIN"
$PWD/rsdns srv -d $TESTDOMAIN -n _tcp._sip.$TESTDOMAIN -T arecord.$TESTDOMAIN -p 5 -P 5060 -W 5