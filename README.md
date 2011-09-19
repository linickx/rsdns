# RSDNS Tools #

RSDNS tools are (_will be_) a set of shell scripts for the [rackspace cloud dns api](http://docs.rackspace.com/cdns/api/v1.0/cdns-devguide/content/index.html).

## rsdns-domain.sh ##

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

## rsdns-a.sh ##

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

## rsdns-did.sh ##

RSDNS Delete by ID (did), delete a record by ID.  
I've noticed that rsdns-list doesn't parse some records properly, whilst I sort that out this tool allows these records to be deleted by their record ID. The record ID is always the 1st column printed by rsdns-list.

Options:

*  -u username
*  -a api key
*  -d domain name
*  -i redord ID
*  -k use the UK (London) servers
*  -h help

Usage:  
To delete a record:  
`./rsdns-did.sh -u linickx -a 123456 -d www.linickx.com -i MX-1234`  


## rsdns-mx.sh ##

RSDNS MX, create and delete an MX record within an existing domain.

Options:

*  -u username
*  -a api key
*  -d domain for the record
*  -n name for the record
*  -D data for the record
*  -p MX priority
*  -t TTL
*  -x Delete a record
*  -k use the UK (London) servers
*  -h help

Usage:  
MX record creatation is a little more complicated than A records; the record name is the path for recieving mail in most cases this is the same as the domain, but can be a hostname. The DATA for the record is the hostname of the server recieving the email. The priority is 10 by default and can be used to distribute the mail accross different servers. Below is an email for sending mail to linickx.com    
`./rsdns-a.sh -u linickx -a 123456 -d linickx.com -n linickx.com -D mail.linickx.com -p 5`  
Below is an example for sending email to a server.  
`./rsdns-a.sh -u linickx -a 123456 -d linickx.com -n host.linickx.com -D host.linickx.com -p 10`  
To delete a record, use rsdns-did.sh

## rsdns-txt.sh ##

RSDNS TXT, create and delete TXT records within an existing domain.

Options:

*  -u username
*  -a api key
*  -d domain for the record
*  -n name for the record
*  -D data for the record
*  -t TTL
*  -x Delete a record
*  -k use the UK (London) servers
*  -h help

Usage:  
TXT records can be used to create SPF & DKIM records, below is an example to create an SPF record.  
`./rsdns-a.sh -u linickx -a 123456 -d linickx.com -n linickx.com -D "include:aspmx.googlemail.com ~all"` 
To delete a record, use rsdns-did.sh

---

### _Creditz_ ###
A big thank you [jsquared](http://jsquaredconsulting.com/blog) for publishing [rscurl](https://github.com/jsquared) as without it I would never have got started ;)