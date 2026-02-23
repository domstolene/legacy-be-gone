# find java build tool
Looks for maven or gradle build files to determine if project is gradle or maven.

Requires:
- [fd find](https://github.com/sharkdp/fd)

## Actions
To determine java build tool, run this two commands:

```shell
fd 'build.gradle(.kts)?' --quiet && echo gradle
fd pom.xml --quiet && echo maven
```

## Edge cases
In edge cases, where both build tools are found, run this command that counts build files and chooses the most likely based on number of files found:

```shell
fd '(pom.xml|build.gradle)' \
  | sed -e 's|.*build.gradle.*|gradle|' -e 's|.*pom.xml.*|maven|' \
  | sort \
  | uniq -c \
  | head -n1 \
  | tr -s " " \
  | cut -d" " -f3
```
