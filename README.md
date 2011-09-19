# RSDNS Tools #

RSDNS tools are (_will be_) a set of shell scripts for the [rackspace cloud dns api](http://docs.rackspace.com/cdns/api/v1.0/cdns-devguide/content/index.html).

## rsdns-domain.sh

RSDNS Domain, create and delete a domain from rackspace cloud DNS

Options:

*  -u username
*  -a api key
*  -d domain
*  -e email address
*  -t TTL
*  -x Delete a domain
*  -k use the UK (London) servers
*  -h help

Usage:
To create a record:  
`./rsdns-domain.sh -u linickx -a 123456 -d www.linickx.com -e spam@linickx.com`  
To delete a record:  
`./rsdns-domain.sh -u linickx -a 123456 -d www.linickx.com -x` 

## rsdns-list.sh ##

RSDNS List, lists all the domains for an account, or the records for a domain.

Options:

*  -u username
*  -a api key
*  -d domain
*  -k use the UK (London) servers
*  -h help

Usage:
To list my domains:  
`./rsdns-list.sh -u linickx -a 123456`  
To list records in a domain  
`./rsdns-list.sh -u linickx -a 123456 -d linickx.com`

## rdsnd-a.sh ##

RSDNS A, create and delete an A record within an existing domain.

Options:

*  -u username
*  -a api key
*  -n fully qualified hostname
*  -i IP address
*  -t TTL
*  -x Delete a record
*  -k use the UK (London) servers
*  -h help

Usage:
To create a record:  
`./rsdns-a.sh -u linickx -a 123456 -n www.linickx.com -i 123.123.123.123`  
To delete a record:  
`./rsdns-a.sh -u linickx -a 123456 -n www.linickx.com -x` 

---

### _Creditz_ ###
A big thank you [jsquared](http://jsquaredconsulting.com/blog) for publishing [rscurl](https://github.com/jsquared) as without it I would never have got started ;)