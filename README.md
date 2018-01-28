
# shodan-tcl
## Tcl library for Shodan
Shodan is advanced search engine for Internet connected devices.
This library is a TCL interface to [Shodan API](https://developer.shodan.io/api).

Library currently supports:
- Search API
- Streaming API
- Exploits API

## Requirements
Library requires:
- Shodan API key
- TCL 8.6
or
- TCL 8.5 + TclOO packages installed
## Instalation
Repository content shall be placed in the TCL library path

## Loading library
```
package require shodan
```

## Examples
### Initialization of Shodan API
```
set s_api [shodan_api new <api_key>]
```

### Initialization of Shodan streaming API
```
set s_stream_api [shodan_stream_api new <api_key>]
```

### Initialization of Shodan streaming API
```
set s_exploits_api [shodan_exploits_api new <api_key>]
```

### Search methods
#### ip
```
$s_api ip "1.2.3.4"
```

#### count
```
$s_api count "country:PL CentOS" "city"
```
#### search
```
$s_api search "country:PL CentOS city:Poznan"
```
#### ports
```
$s_api ports
```

### Shodan On-Demand Scanning
#### protocols
```
$s_api protocols
```
#### scan
```
$s_api scan [list 1.2.3.4]
```
#### scanStatus
```
$s_api scanStatus DCabcR7xTnJeuFab
```
### Utility Methods
#### httpHeaders
```
$s_api httpHeaders

```
#### myIp
```
$s_api myIp
```

### Account Methods
#### profile
```
$s_api profile
```

### DNS Methods
#### resolve
```
$s_api resolve [list google.com bing.com]
```
#### reverse
```
$s_api reverse [list 74.125.227.230 204.79.197.200]
```

### API Status Methods
#### apiInfo
```
$s_api apiInfo
```

### Shodan Network Alerts
#### alert
```
$s_api alert test_alert "8.8.0.0" 120
```
#### alertInfo
```
$s_api alertInfo
```
#### alertDelete
```
$s_api deleteAlert 5H0P1PGFLO2ETQ2L
```
### Shodan Directory Methods
#### query
```
$s_api query 1 votes asc
```
#### querySearch
```
$s_api querySearch webcam
```

### Shodan Bulk Data
#### data
```
$s_api data
$s_api data <dataset>
```

### Shodan streaming API
#### streamBanners
```
$s_stream_api streamBanners
```
#### streamAsn
```
$s_stream_api stramAsn [list 3303 32475]
```
#### streamCountries
```
$s_stream_api steramCountries [list DE US]
```
#### streamPorts
```
$s_stream_api streamPorts [list 1434 27017 6379]
```
#### streamAlert
```
$s_stream_api streamAlert
```

### Shodan exploits API
#### count
```
$s_exploits_api count "Proftpd"
```

#### search
```
$s_exploits_api search "Proftpd"
```
