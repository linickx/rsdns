# RSDNS Tools #

RSDNS tools are (_will be _) a set of shell scripts for the [rackspace cloud dns api](http://docs.rackspace.com/cdns/api/v1.0/cdns-devguide/content/index.html)

## rsdns-list.sh ##

RSDNS List, lists all the domains for an account, or the records for a domain.

Options:
* -u username
* -a api key
* -d domain
* -k use the UK (London) servers
* -h help

Usage:
To list my domains:
`./rsdns-list.sh -u linickx -a 123456`
To list records in a domain
`./rsdns-list.sh -u linickx -a 123456 -d linickx.com`

### Creditz ###
A big thank you [jsquared](http://jsquaredconsulting.com/blog) for publishing [rscurl](https://github.com/jsquared) as without it I would never have got started ;)