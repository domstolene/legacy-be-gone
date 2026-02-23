With gradle version as input, find OpenRewrite instructions with:

```shell
GRADLE_VERSION=<GRADLE_VERSION_FOUND> \
  curl --silent https://raw.githubusercontent.com/openrewrite/rewrite-docs/refs/heads/master/docs/recipes/gradle/migratetogradle$GRADLE_VERSION.md \
  | awk 'found && /^## /{exit} /^## Usage/{found=1} found{print}' \
  | awk '/<TabItem value="gradle"/{skip=1} skip && /<\/TabItem>/{skip=0; next} !skip{print}' \
  | awk '/<TabItem value="moderne-cli"/{skip=1} skip && /<\/TabItem>/{skip=0; next} !skip{print}' \
  | grep -vE '^</?Tab'
```

Expected output is a markdown snippet with instructions for how to use OpenRewrite plugin in a gradle init script.
