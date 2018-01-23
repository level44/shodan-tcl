################################################################################
#   shodan.tcl
#
#
#   ----------------------------------------------------------------------------
#   Revision: 0.0.2
#   Author: level44
#
#   ----------------------------------------------------------------------------
#****h* /shodan_api
# DESCRIPTION
#   Library allows to comunicate with Shodan database
#
# Examples
#
#******
################################################################################
################################################################################
#
#

package provide shodan 0.0.1

package require http
package require TclOO
package require tls
package require json
http::register https 443 [list ::tls::socket -tls1 1]

oo::class create shodan_api {
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
    #   2 element List with returnCode and dictionary as result
    #       first element - error code
    #           >0 OK
    #       second element - dictionary
    #
    # USAGE
    #   set s [shodan_api <api_key>]
    #
    #******
    constructor {api_key} {
        set Api_key $api_key
        set Debug 1
        set Api_url "https://api.shodan.io"
    }

    method Debug {str} {
        if {$Debug} {
            puts $str
        }
    }

    #****p* shodan/ip
    # NAME
    #   ip
    #
    # DESCRIPTION
    #   Returns all services that have been found on the given host IP.
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

    #****p* shodan/count
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

    #****p* shodan/search
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

    #****p* shodan/ports
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

    #****p* shodan/protocols
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

    #****p* shodan/scan
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

    #****p* shodan/scanStatus
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
    method Execute {path method data} {
        my Debug "Called"
        switch $method {
            GET {
                my Debug "Executed for $path[http::formatQuery {*}?$data]"
                set tok [http::geturl $path?[http::formatQuery {*}$data] -type text/json -method $method]
            }
            POST {
                my Debug "POST method"
                my Debug "$path\n$data"
                set tok [http::geturl $path -query [http::formatQuery {*}$data] -type application/json -method $method]
            }
            PUT {
                my Debug "PUT method"
                my Debug "$path\n$data"
                set tok [http::geturl $path -query [http::formatQuery {*}$data -type application/json -method $method]
            }
        }
        set ret [ http::data $tok ]
        ::http::cleanup $tok
        if {[catch {set ret [::json::json2dict $ret]}]} {
            return [list -1 "Not possible to parse json"]
        } else {
            return [list 0 $ret]
        }
    }
}