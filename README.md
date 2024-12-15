## REGION-PROXY
HTTP proxy with customizable ExitNodes country settings using Glider with Tor network.

### Variables:
|Key|Default value|Example|Is necessary|
|-|-|-|-|
|`ADMIN`||`admin`|No|
|`PASSWORD`||`admin`|No|
|`REGION`|`["US"]`|`["us","se","fr","jp"]`|No|

### Usage:

#### In docker command
```
docker run -p 8443:8443 -e REGION='["us","de"]' saika2077/region-proxy:latest
```
#### In docker-compose.yml
```yaml
version: '3.8'
services:
  app:
    image: saika2077/region-proxy
    ports:
      - "8443:8443"
    environment:
      - REGION='["us","de"]'
```

### Test:
```bash
curl https://api.ip2location.io -x http://127.0.0.1:8443
```
or
```bash
curl https://api.ip2location.io -x http://admin:admin@127.0.0.1:8443
```