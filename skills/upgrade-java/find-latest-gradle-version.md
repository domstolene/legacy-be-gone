To find current gradle version, run

```shell
curl --silent https://services.gradle.org/versions/current \
  | yq .version \
  | cut -d. -f1
```
