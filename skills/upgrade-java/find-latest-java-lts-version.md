# Description
Find the latest Long Term Support (LTS) Java versions available from Adoptium Temurin.

Requires:
- curl
- [jq](https://jqlang.org)

## Actions
Run this command to find the latest LTS Adoptium Java version available:

```shell
curl -s https://api.adoptium.net/v3/info/available_releases \
  | jq .available_lts_releases[] \
  | sort -n \
  | tail -n1
```
