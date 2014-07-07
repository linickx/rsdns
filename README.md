# RSDNS Tools #

RSDNS tools are (_will be_) a set of shell scripts for the [rackspace cloud dns](http://www.rackspace.com/cloud/cloud_hosting_products/dns/) [api](http://docs.rackspace.com/cdns/api/v1.0/cdns-devguide/content/index.html).

**Requires** - bash, curl, gsub, awk & sed ( __+dig for the dhcp client__ )

## $PATH ##

The rsdns scripts have been designed to be called independently so that administrators can batch process DNS record management. Typing commands like "rsdns-list.sh" aren't very user friendly, for the one off *typed by hand* activities  a "master script" called `rsdns` exists.  

`rsdns` can be used to call the subscripts below, for example, once you add `rsdns` to your $PATH you can use commands like:  
```
rsdns list -d www.linickx.com
``` 

You can add `rsdns` to you path in one of two ways:  

- add the whole rsdns directory to your $PATH environment variable ( *see example below* )  ... or...
- symlink `rsdns` to a folder like /usr/local/bin, which is already in your $PATH

## The Config File ~/.rsdns_config ##

To reduce the amount of typing and to enable usage of rsdns in your $PATH, a basic config file is supported. The following Variables are supported:  

*  RSUSER - Your rackspace username
*  RSAPIKEY - Your rackspace api key
*  UKAUTH - set to 1 if you want to use the London (UK) servers
*  RSPATH - this is where you have installed RSDNS
*  QUIET - disable the output

Example:  

    [LINICKX@SERVER ~]$ cat ~/.rsdns_config 
    RSUSER=linickx  
    RSAPIKEY=123456  
    RSPATH=~/rsdns/  
    UKAUTH=1 
    [LINICKX@SERVER ~]$


$PATH Example:

    [LINICKX@SERVER ~]$ PATH=$PATH:~/rsdns/;export PATH  
    [LINICKX@SERVER ~]$ echo $PATH  
    /usr/kerberos/bin:/usr/local/bin:/bin:/usr/bin:/usr/X11R6/bin:/home/LINICKX/bin:/home/LINICKX/rsdns/  
    [LINICKX@SERVER ~]$ rsdns-list.sh  
     123456  - test.linickx.com  
    [LINICKX@SERVER ~]$


## The scripts ##

The following scripts are provided with rsdns, help and examples for each are listed below

### rsdns-domain.sh ###

RSDNS Domain, create and delete a domain from rackspace cloud DNS

Options:

*  -u username
*  -a api key
*  -c client ID (for cloud sites users)
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

### rsdns-list.sh ###

RSDNS List, lists all the domains for an account, or the records for a domain.

Options:

*  -u username
*  -a api key
*  -c client ID (for cloud sites users)
*  -d domain
*  -k use the UK (London) servers
*  -h help

Usage:
To list my domains:  
`./rsdns-list.sh -u linickx -a 123456`  
To list records in a domain  
`./rsdns-list.sh -u linickx -a 123456 -d linickx.com`

### rsdns-a.sh ###

RSDNS A, create and delete an A record within an existing domain.

Options:

*  -u username
*  -a api key
*  -c client ID (for cloud sites users)
*  -n fully qualified hostname
*  -i IP address
*  -t TTL
*  -x Delete a record
*  -U Update an existing record
*  -k use the UK (London) servers
*  -h help

Usage:  
To create a record:  
`./rsdns-a.sh -u linickx -a 123456 -n www.linickx.com -i 123.123.123.123`  
To delete an A record:  
`./rsdns-a.sh -u linickx -a 123456 -n www.linickx.com -x`  
To update an existing record:  
`./rsdns-a.sh -u linickx -a 123456 -n www.linickx.com -i 111.222.111.222 -U`  
Wildcard records are supported, for example  
`./rsdns-a.sh -u linickx -a 123456 -n *.linickx.com -i 123.123.123.123`  
To create a record with no prefix:  
`./rsdns-a.sh -u linickx -a 123456 -d linickx.com -n linickx.com -i 123.123.123.123` 


### rsdns-aaaa.sh ###

RSDNS AAAA, create and delete an AAAA record within an existing domain.

Options:

*  -u username
*  -a api key
*  -c client ID (for cloud sites users)
*  -n fully qualified hostname
*  -i IP address
*  -t TTL
*  -x Delete a record
*  -U Update an existing record
*  -k use the UK (London) servers
*  -h help

Usage:  
To create a record:  
`./rsdns-aaaa.sh -u linickx -a 123456 -n www.linickx.com -i 4321:0:1:2:3:4:567:89ab`  
To delete an A record:  
`./rsdns-aaaa.sh -u linickx -a 123456 -n www.linickx.com -x`  
To update an existing record:  
`./rsdns-aaaa.sh -u linickx -a 123456 -n www.linickx.com -i 4321:0:1:2:3:4:567:89ab -U`  
Wildcard records are supported, for example  
`./rsdns-aaaa.sh -u linickx -a 123456 -n *.linickx.com -i 4321:0:1:2:3:4:567:89ab`  

### rsdns-cn.sh ###

RSDNS CN, create and delete an CNAME record within an existing domain.

Options:

*  -u username
*  -a api key
*  -c client ID (for cloud sites users)
*  -n hostname of the new CNAME
*  -r the RECORD the CNAME points to
*  -t TTL
*  -x Delete a record
*  -U Update an existing record
*  -k use the UK (London) servers
*  -h help

Usage:  
CNAMEs are a little confusing, you are creating an alias to another record. To keep the usage syntax the same, -n is the name of the new record you are creating, -r is the record you are aliasing. For example, below www.linickx.com is the new record & test.linickx.com is an existing A record.  
To create a record:  
`./rsdns-cn.sh -u linickx -a 123456 -n www.linickx.com -r test.linickx.com`  
To delete a CN record:  
`./rsdns-cn.sh -u linickx -a 123456 -n www.linickx.com -x`  
To update an existing record:  
`./rsdns-cn.sh -u linickx -a 123456 -n www.linickx.com -r test2.linickx.com -U`  

### rsdns-did.sh ###

RSDNS Delete by ID (did), delete a record by ID.  
I've noticed that rsdns-list doesn't parse some records properly, whilst I sort that out this tool allows these records to be deleted by their record ID. The record ID is always the 1st column printed by rsdns-list.

Options:

*  -u username
*  -a api key
*  -c client ID (for cloud sites users)
*  -d domain name
*  -i redord ID
*  -k use the UK (London) servers
*  -h help

Usage:  
To delete a record:  
`./rsdns-did.sh -u linickx -a 123456 -d www.linickx.com -i MX-1234`  


### rsdns-mx.sh ###

RSDNS MX, create and delete an MX record within an existing domain.

Options:

*  -u username
*  -a api key
*  -c client ID (for cloud sites users)
*  -d domain for the record
*  -n name for the record
*  -D data for the record
*  -p MX priority
*  -t TTL
*  -x Delete a record
*  -k use the UK (London) servers
*  -h help

Usage:  
MX record creation is a little more complicated than A records; the record name is the path for receiving mail in most cases this is the same as the domain, but can be a hostname. The DATA for the record is the hostname of the server receiving the email. The priority is 10 by default and can be used to distribute the mail across different servers. Below is an email for sending mail to linickx.com    
`./rsdns-mx.sh -u linickx -a 123456 -d linickx.com -n linickx.com -D mail.linickx.com -p 5`  
Below is an example for sending email to a server.  
`./rsdns-mx.sh -u linickx -a 123456 -d linickx.com -n host.linickx.com -D host.linickx.com -p 10`  
To delete a record:  
`./rsdns-mx.sh -u linickx -a 123456 -d linickx.com -n linickx.com -x`  
If you have two (or three/four/etc) MX records where the -n (name) is the same, the last record you created will be deleted. To delete a different record use delete by ID (rsdns-did.sh)  

### rsdns-txt.sh ###

RSDNS TXT, create and delete TXT records within an existing domain.

Options:

*  -u username
*  -a api key
*  -c client ID (for cloud sites users)
*  -d domain for the record
*  -n name for the record
*  -D data for the record
*  -t TTL
*  -x Delete a record
*  -k use the UK (London) servers
*  -h help

Usage:  
TXT records can be used to create SPF & DKIM records, below is an example to create an SPF record.  
`./rsdns-txt.sh -u linickx -a 123456 -d linickx.com -n linickx.com -D "v=spf1 include:aspmx.googlemail.com ~all"`  
To delete a TXT record:  
`./rsdns-txt.sh -u linickx -a 123456 -d linickx.com -n linickx.com -x` 


### rsdns-srv ###

RSDNS SRV, create and delete SRV records within an existing domain, the usage / functionality here is the same as TXT records.

Options:

*  -u username
*  -a api key
*  -c client ID (for cloud sites users)
*  -d domain for the record
*  -n name for the record
*  -D data for the record
*  -t TTL
*  -x Delete a record
*  -k use the UK (London) servers
*  -h help

Usage:  
TXT records can be used to create SPF & DKIM records, below is an example to create an SPF record.  
`./rsdns-srv.sh -u linickx -a 123456 -d linickx.com -n _tcp._sip.linickx.com -D "1 3443 sip.foo.com\"`  
To delete a SRV record:  
`./rsdns-srv.sh -u linickx -a 123456 -d linickx.com -n _tcp._sip.linickx.com -x` 

### rsdns-ns ###

RSDNS NS, update the Name Server records for a domain (This makes the most sense for sub domains).

Options:

*  -u username
*  -a api key
*  -c client ID (for cloud sites users)
*  -d domain for the record
*  -s name of the old name server (the one you are changing)
*  -S new name server
*  -t TTL
*  -k use the UK (London) servers
*  -h help

Usage:  
Currently you can only update records, this should be enough for most use cases.
`./rsdns-ns.sh -u linickx -a 123456 -d linickx.com -s dns1.stabletransit.com -S ns.example.com`

If you are modifying a client's dns
`./rsdns-ns.sh -u linickx -a 123456 -d linickx.com -s dns1.stabletransit.com -S ns.example.com -c 123456`

## Dynamic DNS Client ##

Dynamic DNS is where a clients IP address changes regularly and it's A record is updated as appropriate. This script is slightly different to the others; example usage is given below, I have a full description on [this blog post](http://www.linickx.com/3442/building-a-free-dynamic-dns-client-with-rackspace-cloud).

### rsdns-dc ###

RSDNS Dynamic Client (DC), a dynamic DNS client for rackspace cloud. Setup an A record, and use cron to call rsdns-dc.sh to keep the record up to date.  
To use rsdns-dc.sh you will need a config file (_see above_) and dig installed. This script makes an http request to [icanhazip.com](http://icanhazip.com) to determine your current IP address, firewalls and proxies will need to be setup as appropriate.

Usage: 

1.  Setup a config file (/home/linickx/.rsdns_config)
2.  Create an A record
`./rsdns-a.sh -n www.linickx.com -i 123.123.123.123 -t 3600  `
3.  Run the script 
`./rsdns-dc.sh -n dynamichost.linickx.com`

Below is an example of my */etc/cron.d/rsdns-dc* crontab file which updates my IP address every 2 hours.  

    
    * */2  * * *     linickx /home/linickx/rsdns/rsdns-dc.sh -n dynamichost.linickx.com &>/dev/null
         

---

### _Creditz_ ###
A big thank you [jsquared](http://jsquaredconsulting.com/blog) for publishing [rscurl](https://github.com/jsquared) as without it I would never have got started ;)  

An even bigger, thank you to those in the [CONTRIB.md](https://github.com/linickx/rsdns/blob/master/CONTRIB.md) file who have submitted code and Pull Requests as you make this code worthy to be published on the Internet :D
