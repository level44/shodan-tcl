################################################################################
#   shodan.tcl
#
#
#   ----------------------------------------------------------------------------
#   Revision: 1.0.0
#   Author: level44
#
#   ----------------------------------------------------------------------------
#****h* /shodan_api
# DESCRIPTION
#   Library allows to comunicate with Shodan database
#
# Basic examples
#   set s_api [shodan_api new <api_key>]
#   set s_stream_api [shodan_stream_api new <api_key>]
#
#
#******
################################################################################
################################################################################
#
#

package provide shodan 1.0.0

package require http
package require TclOO
package require tls
package require json
http::register https 443 [list ::tls::socket -tls1 1]

oo::class create shodan {
    variable Api_key
    variable Debug
    variable Api_url

    #****p* shodan/constructor
    # NAME
    #   constructor
    #
    # DESCRIPTION
    #   Create shodan object
    #
    # ARGUMENTS
    #   api_key - shodan api key
    #
    # RESULT
    #   Object handler
    #
    # USAGE
    #   set s [shodan <api_key>]
    #
    #******
    constructor {api_key} {
        set Api_key $api_key
        set Debug 0
    }

    # method Validation {args} {
    #     my Debug "Validation called for [self target] with args: $args"
    #     set status 0
    #     set msg {}
    #     switch [self target] {
    #         "ip" {

    #         }
    #         "count" {

    #         }
    #         "search" {

    #         }
    #         "scan" {

    #         }
    #         "scanStatus" {

    #         }
    #         "resolve" {

    #         }
    #         "reverse" {

    #         }
    #     }
    #     if {$status eq 0} {
    #         next {*}$args
    #     } else {
    #         #break call due to wrong parameters
    #         return [list $status $msg]
    #     }
    # }

    #****ip* shodan/Debug
    # NAME
    #   Debug
    #
    # DESCRIPTION
    #   Private procedure used to print out debug informations
    #
    # ARGUMENTS
    #   str - string to print out if debuging is enabled
    #
    # RESULT
    #
    # USAGE
    #   my Debug "test debug"
    #
    #******
    method Debug {str} {
        if {$Debug} {
            puts $str
        }
    }

    #****ip* shodan/Execute
    # NAME
    #   Execute
    #
    # DESCRIPTION
    #   Private procedure used to perform call to JIRA server
    #
    # ARGUMENTS
    #   path - path to method
    #   method - method to call
    #   query - query data
    #
    # RESULT
    #   2 element List with returnCode and dictionary as result
    #       first element - error code
    #           >0 OK
    #       second element - dictionary
    #
    # USAGE
    #
    #******
    method Execute {path method data {mode {format}}} {
        my Debug "Called"
        switch $method {
            GET {
                my Debug "Executed for $path?[http::formatQuery {*}$data]"
                set tok [http::geturl $path?[my FormatQuery $data $mode] -type text/json -method $method]
            }
            POST {
                my Debug "POST method"
                my Debug "$path\n$data"
                set tok [http::geturl $path -query [my FormatQuery $data $mode] -type application/json -method $method]
            }
            PUT {
                my Debug "PUT method"
                my Debug "$path\n$data"
                set tok [http::geturl $path -query [my FormatQuery $data $mode] -type application/json -method $method]
            }
            DELETE {
                my Debug "DELETE method"
                my Debug "$path\n$data"
                set tok [http::geturl $path -query [my FormatQuery $data $mode] -type application/json -method $method]
            }
        }
        set ret [ http::data $tok ]
        my Debug "Response:"
        my Debug $ret
        ::http::cleanup $tok
        if {[catch {set ret [::json::json2dict $ret]}]} {
            return [list -1 "Not possible to parse json"]
        } else {
            return [list 0 $ret]
        }
    }

    #****ip* shodan/FormatQuery
    # NAME
    #   FormatQuery
    #
    # DESCRIPTION
    #   Private procedure to format query
    #
    # ARGUMENTS
    #   data - source data
    #   mode - raw/format
    #
    # RESULT
    #   Formated or original data (depends on mode setting)
    #
    # USAGE
    #
    #******
    method FormatQuery {data mode} {
        if {$mode eq "format"} {
            return [http::formatQuery {*}$data]
        } else {
            return $data
        }
    }

    #filter Validation
}

oo::class create shodan_api {
    superclass shodan
    variable Api_key
    variable Debug
    variable Api_url

    constructor {api_key} {
        set Api_url "https://api.shodan.io"
        next $api_key
    }

    #****p* shodan_api/ip
    # NAME
    #   ip
    #
    # DESCRIPTION
    #   Return all services that have been found on the given host IP.
    #
    # ARGUMENTS
    #   ip - ip address to check
    #
    # RESULT
    #   2 element List with returnCode and dictionary as result
    #       first element - error code
    #           >0 OK
    #       second element - dictionary
    #
    # USAGE
    #   $s ip "1.2.3.4"
    #
    #******
    method ip {ip} {
        set path "$Api_url/shodan/host/$ip"
        return [my Execute $path GET [list key $Api_key]]
    }

    #****p* shodan_api/count
    # NAME
    #   count
    #
    # DESCRIPTION
    #   Shearch for provided query and count results.
    #
    # ARGUMENTS
    #   query - string contains query to search
    #   facets - a comma-separated list of properties to get summary information on
    #
    # RESULT
    #   2 element List with returnCode and dictionary as result
    #       first element - error code
    #           >0 OK
    #       second element - dictionary
    #
    # USAGE
    #   $s count "country:PL CentOS" "city"
    #
    #******
    method count {query facets} {
        set path "$Api_url/shodan/host/count"
        return [my Execute $path GET [list key $Api_key query $query facets $facets]]
    }

    #****p* shodan_api/search
    # NAME
    #   search
    #
    # DESCRIPTION
    #   Shearch for provided query.
    #
    # ARGUMENTS
    #   query - string contains query to search
    #   facets - a comma-separated list of properties to get summary information on
    #   page - the page number to page through results 100 at a time (default: 1)
    #   minify - True or False; whether or not to truncate some of the larger fields (default: True)
    #
    # RESULT
    #   2 element List with returnCode and dictionary as result
    #       first element - error code
    #           >0 OK
    #       second element - dictionary
    #
    # USAGE
    #   $s search "country:PL CentOS city:Poznan"
    #
    #******
    method search {query {facets {}} {page 1} {minify True}} {
        set path "$Api_url/shodan/host/search"
        set data [list key $Api_key query $query page $page minify $minify]
        if {$facets != {}} {
            lappend data facets $facets
        }
        return [my Execute $path GET $data]
    }

    #****p* shodan_api/ports
    # NAME
    #   ports
    #
    # DESCRIPTION
    #   Return a list of port numbers that the crawlers are looking for.
    #
    # ARGUMENTS
    #
    # RESULT
    #   2 element List with returnCode and dictionary as result
    #       first element - error code
    #           >0 OK
    #       second element - dictionary
    #
    # USAGE
    #   $s ports
    #
    #******
    method ports {} {
        set path "$Api_url/shodan/ports"
        set data [list key $Api_key]
        return [my Execute $path GET $data]
    }

    #****p* shodan_api/protocols
    # NAME
    #   protocols
    #
    # DESCRIPTION
    #   Return all protocols that can be used when performing on-demand Internet scans
    #
    # ARGUMENTS
    #
    # RESULT
    #   2 element List with returnCode and dictionary as result
    #       first element - error code
    #           >0 OK
    #       second element - dictionary
    #
    # USAGE
    #   $s protocols
    #
    #******
    method protocols {} {
        set path "$Api_url/shodan/protocols"
        set data [list key $Api_key]
        return [my Execute $path GET $data]
    }

    #****p* shodan_api/scan
    # NAME
    #   scan
    #
    # DESCRIPTION
    #   Request Shodan to crawl an IP/ netblock
    #
    # ARGUMENTS
    #   ips - list of ips to scan
    #
    # RESULT
    #   2 element List with returnCode and dictionary as result
    #       first element - error code
    #           >0 OK
    #       second element - dictionary
    #
    # USAGE
    #   $s scan [list 1.2.3.4]
    #
    #******
    method scan {ips} {
        set path "$Api_url/shodan/scan?key=$Api_key"
        set data [list ips [join $ips ,]]
        return [my Execute $path POST $data]
    }

    #****p* shodan_api/scanStatus
    # NAME
    #   scanStatus
    #
    # DESCRIPTION
    #   Request the status of a scan request
    #
    # ARGUMENTS
    #   id - scan id
    #
    # RESULT
    #   2 element List with returnCode and dictionary as result
    #       first element - error code
    #           >0 OK
    #       second element - dictionary
    #
    # USAGE
    #   $s scanStatus DCabcR7xTnJeuFab
    #
    #******
    method scanStatus {id} {
        set path "$Api_url/shodan/scan/$id"
        set data [list key $Api_key]
        return [my Execute $path GET $data]
    }

    #****p* shodan_api/alert
    # NAME
    #   alert
    #
    # DESCRIPTION
    #   Create a network alert for a defined IP/ netblock
    #   which can be used to subscribe to changes/ events
    #   that are discovered within that range.
    #
    # ARGUMENTS
    #   name - alert name
    #   filters - criteria for triggering alert (currently only ip filter is supported)
    #   expires - optional number of seconds that the alert should be active
    #
    # RESULT
    #   2 element List with returnCode and dictionary as result
    #       first element - error code
    #           >0 OK
    #       second element - dictionary
    #
    # USAGE
    #   $s alert test_alert "8.8.0.0" 120
    #
    #******
    method alert {name ip {expires {0}}} {
        set path "$Api_url/shodan/alert?key=$Api_key"
        set data "{\"name\":\"$name\",\"expires\":$expires,\"filters\":{\"ip\": \[\"$ip\"\]}}"
        my Debug $data
        return [my Execute $path POST $data raw]
    }

    #****p* shodan_api/alertInfo
    # NAME
    #   alertInfo
    #
    # DESCRIPTION
    #   Return the information about a specific network alert or
    #   return the informmation about all network alerts
    #
    # ARGUMENTS
    #   id - allert id (default empty)
    #
    # RESULT
    #   2 element List with returnCode and dictionary as result
    #       first element - error code
    #           >0 OK
    #       second element - dictionary
    #
    # USAGE
    #   $s alertInfo
    #
    #******
    method alertInfo {{id {}}} {
        set data [list key $Api_key]
        if {$id ne {}} {
            set path "$Api_url/shodan/alert/$id/info"
        } else {
            set path "$Api_url/shodan/alert/info"
        }
        return [my Execute $path GET $data]
    }

    #****p* shodan_api/deleteAlert
    # NAME
    #   deleteAlert
    #
    # DESCRIPTION
    #   Delete allert (supported only with tcl 8.6)
    #
    # ARGUMENTS
    #   id - alert id
    #
    # RESULT
    #   2 element List with returnCode and dictionary as result
    #       first element - error code
    #           >0 OK
    #       second element - dictionary
    #
    # USAGE
    #   $s deleteAlert 5H0P1PGFLO2ETQ2L
    #
    #******
    method deleteAlert {id} {
        set path "$Api_url/shodan/alert/$id\?key=$Api_key"
        set data {}
        my Debug $data
        return [my Execute $path DELETE $data]
    }

    #****p* shodan_api/query
    # NAME
    #   query
    #
    # DESCRIPTION
    #   List the saved search queries
    #
    # ARGUMENTS
    #   page - page number over results
    #   sort - votes or timestamp
    #   order - asc or desc
    #
    # RESULT
    #   2 element List with returnCode and dictionary as result
    #       first element - error code
    #           >0 OK
    #       second element - dictionary
    #
    # USAGE
    #   $s query 1 votes asc
    #
    #******
    method query {{page 0} {sort votes} {order asc}} {
        set path "$Api_url/shodan/query"
        set data [list key $Api_key page $page sort $sort order $order]
        return [my Execute $path GET $data]
    }

    #****p* shodan_api/querySearch
    # NAME
    #   guerySearch
    #
    # DESCRIPTION
    #   Search the directory of saved search queries.
    #
    # ARGUMENTS
    #   query - string with definition what to find
    #   page - page number over results
    #
    # RESULT
    #   2 element List with returnCode and dictionary as result
    #       first element - error code
    #           >0 OK
    #       second element - dictionary
    #
    # USAGE
    #   $s querySearch webcam
    #
    #******
    method querySearch {query {page 0}} {
        set path "$Api_url/shodan/query/search"
        set data [list key $Api_key query $query page $page]
        return [my Execute $path GET $data]
    }

    #****p* shodan_api/queryTags
    # NAME
    #   gueryTags
    #
    # DESCRIPTION
    #   List the most popular tags
    #
    # ARGUMENTS
    #   size - number of tags to display (defult 10)
    #
    # RESULT
    #   2 element List with returnCode and dictionary as result
    #       first element - error code
    #           >0 OK
    #       second element - dictionary
    #
    # USAGE
    #   $s queryTags 20
    #
    #******
    method queryTags {{size 10}} {
        set path "$Api_url/shodan/query/tags"
        set data [list key $Api_key size $size]
        return [my Execute $path GET $data]
    }

    #****p* shodan_api/data
    # NAME
    #   data
    #
    # DESCRIPTION
    #   Get a list of available datasets or required dataset
    #
    # ARGUMENTS
    #   dataset - optional dataset name
    #
    # RESULT
    #   2 element List with returnCode and dictionary as result
    #       first element - error code
    #           >0 OK
    #       second element - dictionary
    #
    # USAGE
    #   $s data
    #
    #******
    method data {{dataset {}}} {
        set path "$Api_url/shodan/data"
        if {$dataset eq {}} {
            set data [list key $Api_key]
        } else {
            set data [list key $Api_key dataset $dataset]
        }
        return [my Execute $path GET $data]
    }

    #****p* shodan_api/httpHeaders
    # NAME
    #   httpHeaders
    #
    # DESCRIPTION
    #   Return the HTTP headers that your client sends when connecting to a webserver.
    #
    # ARGUMENTS
    #
    # RESULT
    #   2 element List with returnCode and dictionary as result
    #       first element - error code
    #           >0 OK
    #       second element - dictionary
    #
    # USAGE
    #   $s httpHeaders
    #
    #******
    method httpHeaders {} {
        set path "$Api_url/tools/httpheaders"
        set data [list key $Api_key]
        return [my Execute $path GET $data]
    }

    #****p* shodan_api/myIp
    # NAME
    #   myIp
    #
    # DESCRIPTION
    #   Return my current IP address as seen from the Internet.
    #
    # ARGUMENTS
    #
    # RESULT
    #   2 element List with returnCode and dictionary as result
    #       first element - error code
    #           >0 OK
    #       second element - dictionary
    #
    # USAGE
    #   $s myIp
    #
    #******
    method myIp {} {
        set path "$Api_url/tools/myip"
        set data [list key $Api_key]
        return [my Execute $path GET $data]
    }

    #****p* shodan_api/profile
    # NAME
    #   profile
    #
    # DESCRIPTION
    #   Return information about the Shodan account linked to this API key
    #
    # ARGUMENTS
    #
    # RESULT
    #   2 element List with returnCode and dictionary as result
    #       first element - error code
    #           >0 OK
    #       second element - dictionary
    #
    # USAGE
    #   $s profile
    #
    #******
    method profile {} {
        set path "$Api_url/account/profile"
        set data [list key $Api_key]
        return [my Execute $path GET $data]
    }

    #****p* shodan_api/resolve
    # NAME
    #   resolve
    #
    # DESCRIPTION
    #   Look up the IP address for the provided list of hostnames.
    #
    # ARGUMENTS
    #   hostnames - List of hostnames
    #
    # RESULT
    #   2 element List with returnCode and dictionary as result
    #       first element - error code
    #           >0 OK
    #       second element - dictionary
    #
    # USAGE
    #   $s resolve [list google.com bing.com]
    #
    #******
    method resolve {hostnames} {
        set path "$Api_url/dns/resolve"
        set data [list key $Api_key hostnames [join $hostnames ,]]
        return [my Execute $path GET $data]
    }

    #****p* shodan_api/reverse
    # NAME
    #   reverse
    #
    # DESCRIPTION
    #   Look up the hostnames that have been defined for the given list of IP addresses.
    #
    # ARGUMENTS
    #   hostnames - List of ip addresses
    #
    # RESULT
    #   2 element List with returnCode and dictionary as result
    #       first element - error code
    #           >0 OK
    #       second element - dictionary
    #
    # USAGE
    #   $s reverse [list 74.125.227.230 204.79.197.200]
    #
    #******
    method reverse {ips} {
        set path "$Api_url/dns/reverse"
        set data [list key $Api_key ips [join $ips ,]]
        return [my Execute $path GET $data]
    }

    #****p* shodan_api/apiInfo
    # NAME
    #   apiInfo
    #
    # DESCRIPTION
    #   Return information about the API plan belonging to the given API key
    #
    # ARGUMENTS
    #
    # RESULT
    #   2 element List with returnCode and dictionary as result
    #       first element - error code
    #           >0 OK
    #       second element - dictionary
    #
    # USAGE
    #   $s apiInfo
    #
    #******
    method apiInfo {} {
        set path "$Api_url/api-info"
        set data [list key $Api_key]
        return [my Execute $path GET $data]
    }
}

oo::class create shodan_stream_api {
    superclass shodan
    variable Api_key
    variable Debug
    variable Api_url

    constructor {api_key} {
        set Api_url "https://stream.shodan.io"
        next $api_key
    }

    #****p* shodan_stream_api/streamBanners
    # NAME
    #   streamBanners
    #
    # DESCRIPTION
    #   This stream provides ALL of the data that Shodan collects.
    #
    # ARGUMENTS
    #
    # RESULT
    #   2 element List with returnCode and dictionary as result
    #       first element - error code
    #           >0 OK
    #       second element - dictionary
    #
    # USAGE
    #   $s streamBanners
    #
    #******
    method streamBanners {{dataset {}}} {
        set path "$Api_url/shodan/banners"
        set data [list key $Api_key]
        return [my Execute $path GET $data]
    }

    #****p* shodan_stream_api/streamAsn
    # NAME
    #   streamAsn
    #
    # DESCRIPTION
    #   This stream filtered by ASN
    #
    # ARGUMENTS
    #   asn - list of ASNs (for example 3303 32475)
    #
    # RESULT
    #   2 element List with returnCode and dictionary as result
    #       first element - error code
    #           >0 OK
    #       second element - dictionary
    #
    # USAGE
    #   $s stramAsn [list 3303 32475]
    #
    #******
    method streamAsn {{asn {}}} {
        set path "$Api_url/shodan/asn/[join $asn ,]"
        set data [list key $Api_key]
        return [my Execute $path GET $data]
    }

    #****p* shodan_stream_api/streamCountries
    # NAME
    #   streamCountries
    #
    # DESCRIPTION
    #   This stream filtered by Country
    #
    # ARGUMENTS
    #   countries - list of countries (for example DE US)
    #
    # RESULT
    #   2 element List with returnCode and dictionary as result
    #       first element - error code
    #           >0 OK
    #       second element - dictionary
    #
    # USAGE
    #   $s steramCountries [list DE US]
    #
    #******
    method streamCountries {{countries {}}} {
        set path "$Api_url/shodan/countries/[join $countries ,]"
        set data [list key $Api_key]
        return [my Execute $path GET $data]
    }

    #****p* shodan_stream_api/streamPorts
    # NAME
    #   streamPorts
    #
    # DESCRIPTION
    #   This stream filtered by Ports
    #
    # ARGUMENTS
    #   ports - list of ports (for example 1434 27017 6379)
    #
    # RESULT
    #   2 element List with returnCode and dictionary as result
    #       first element - error code
    #           >0 OK
    #       second element - dictionary
    #
    # USAGE
    #   $s streamPorts [list 1434 27017 6379]
    #
    #******
    method streamPorts {{ports {}}} {
        set path "$Api_url/shodan/ports/[join $ports ,]"
        set data [list key $Api_key]
        return [my Execute $path GET $data]
    }

    #****p* shodan_stream_api/streamAlert
    # NAME
    #   streamAlert
    #
    # DESCRIPTION
    #   Stream all or defined allert
    #
    # ARGUMENTS
    #   alert - optional allert id
    #
    # RESULT
    #   2 element List with returnCode and dictionary as result
    #       first element - error code
    #           >0 OK
    #       second element - dictionary
    #
    # USAGE
    #   $s streamAlert
    #
    #******
    method streamAlert {{alert {}}} {
        if {$alert ne {}} {
            set path "$Api_url/shodan/alert/$alert"
        } else {
            set path "$Api_url/shodan/alert"
        }
        set data [list key $Api_key]
        return [my Execute $path GET $data]
    }
}