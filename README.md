# legacy be gone
Automasjoner for å oppgradere applikasjoner, slik som java-oppdateringer og oppdateringer av rammeverk.

## Oversikt
Se [java-versjoner.md](java-versjoner.md) for oversikten.

[finne-java-versjoner.sh](finne-java-versjoner.sh) finner hvilke java-versjoner som er i bruk i repoene
via githubs API og fuzzy find. Resultatet brukes i [lage-oversikt-versjoner.sh](lage-oversikt-versjoner.sh) for å opprette [java-versjoner.md](java-versjoner.md).

## Java-oppgradering
Det er skrevet en [agent skill](https://agentskills.io/) for Java-oppgradering. For å ta den i bruk:

1. Kopier til felles sted for agent-skills:

   ```shell
   mkdir -p ~/.copilot/skills
   cp -r skills/upgrade-java ~/.copilot/skills/
   ```

2. Åpne [Copilot CLI](https://github.com/features/copilot/cli) i et repo:

   ```shell
   cd et/java/repo
   copilot
   ```

3. Be agenten om å oppgradere Java:

   > ugprade java

Dersom utfallet er dårlig, rediger eller legg til nye steg som trengs i [SKILL.md](skills/upgrade-java/SKILL.md).

## Ressurser
### OpenReWrite
https://docs.openrewrite.org

### Wildfly
https://github.com/wildfly/wildfly-server-migration
