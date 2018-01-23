# shodan-tcl
## Tcl library for Shodan

### Initialization
```
set s [shodan new <api_key>]

```

### Search methods
#### ip
```
$s ip "1.2.3.4"
```

#### count
```
$s count "country:PL CentOS" "city"

```
#### search
```
$s search "country:PL CentOS city:Poznan"

```
#### ports
```
$s ports

```

### Shodan On-Demand Scanning
#### protocols
```
$s protocols

```
#### scan
```
$s scan [list 1.2.3.4]

```
#### scanStatus
```
$s scanStatus DCabcR7xTnJeuFab

```
### Utility Methods
#### httpHeaders
```
$s httpHeaders

```
### myIp
```
$s myIp

```

## TO DO:
- Shodan Network Alerts
- Shodan Directory Methods
- Shodan Bulk Data
- Account Methods
- DNS Methods
- API Status Methods
- Experimental Methods
- Error Handling
