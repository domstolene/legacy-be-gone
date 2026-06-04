# MCP
Her er noen nyttige MCP for å gi KI-agenten bedre tilgang til informasjon den trenger.

## OpenCode
Oppsett for OpenCode legger du i opencode.jsonc i repoet eller ~/.config/opencode/opencode.jsonc for å installere globalt:

```jsonc
{
  "$schema": "https://opencode.ai/config.json"
  "mcp": {
    "codegraph": {
      "type": "local",
      "command": ["codegraph", "serve", "--mcp"]
    },
    "safari": {
      "type": "local",
      "command": ["npx", "safari-mcp"]
    }
  }
}
```

## [Codegraph](https://github.com/colbymchenry/codegraph)
Indekserer koden, slik at agenten kan navigere effektivt. Må installeres globalt og gjøre en indeksering av repoet:

```shell
npx @colbymchenry/codegraph

# i repo
codegraph init -i
```

## [Safari](https://github.com/achiya-automation/safari-mcp)
Agenten kan hente informasjon fra nettsider og gjenbruke dine innlogginger.
