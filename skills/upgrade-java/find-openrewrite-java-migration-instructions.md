With java version as input, find OpenRewrite instructions with:

```shell
JAVA_VERSION=<JAVA_VERSION_FOUND> \
  curl --silent https://raw.githubusercontent.com/openrewrite/rewrite-docs/refs/heads/master/docs/recipes/java/migrate/upgradetojava$JAVA_VERSION.md \
  | awk 'found && /^## /{exit} /^## Usage/{found=1} found{print}' \
  | awk '/<TabItem value="gradle"/{skip=1} skip && /<\/TabItem>/{skip=0; next} !skip{print}' \
  | awk '/<TabItem value="moderne-cli"/{skip=1} skip && /<\/TabItem>/{skip=0; next} !skip{print}'
```

Expected output is a markdown snippet with instructions for how to use OpenRewrite plugin in Gradle or Maven. The tag `<TabItem value="gradle">` indicates that the instructions are for Gradle, while `<TabItem value="maven">` indicates that the instructions are for Maven.
