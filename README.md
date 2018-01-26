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
#### myIp
```
$s myIp

```

### Account Methods
#### profile
```
$s profile

```

### DNS Methods
#### resolve
```
$s resolve [list google.com bing.com]

```
#### reverse
```
$s reverse [list 74.125.227.230 204.79.197.200]
```

### API Status Methods
#### apiInfo
```
$s apiInfo

```

### Shodan Network Alerts
#### alert
```
$s alert test_alert "8.8.0.0" 120
```
#### alertInfo
```
$s alertInfo
```
#### alertDelete
```
$s deleteAlert 5H0P1PGFLO2ETQ2L
```


## TO DO:
- Shodan Directory Methods
- Shodan Bulk Data
- Experimental Methods
- Error Handling
