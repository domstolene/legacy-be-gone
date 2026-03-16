# legacy be gone
Automasjoner for å oppgradere applikasjoner, slik som java-oppdateringer og oppdateringer av rammeverk.

## Oversikt
Se [java-versjoner.md](java-versjoner.md) for oversikten.

[finne-java-versjoner.sh](finne-java-versjoner.sh) finner hvilke java-versjoner som er i bruk i repoene
via githubs API og fuzzy find. Resultatet brukes i [lage-oversikt-versjoner.sh](lage-oversikt-versjoner.sh) for å opprette [java-versjoner.md](java-versjoner.md).

## Java-oppgradering
Det er skrevet en [agent skill](https://agentskills.io/) for Java-oppgradering. For å ta den i bruk:

1. Kopier til felles sted for agent-skills, oppdaterer dersom det allerede eksisterer der fra før:

   ```shell
   mkdir -p ~/.copilot/skills/upgrade-java
   rsync -a --delete skills/upgrade-java/ ~/.copilot/skills/upgrade-java/
   ```

2. Åpne [Copilot CLI](https://github.com/features/copilot/cli) i et repo:

   ```shell
   cd et/java/repo
   copilot
   ```

3. Be agenten om å oppgradere Java:

   > ugprade java

Dersom utfallet er dårlig, rediger eller legg til nye steg som trengs i [SKILL.md](skills/upgrade-java/SKILL.md).

Dersom du ønsker å unngå at agenten venter på input fra deg, kan du gi det i instruksjonen:

   > upgrade java, case number is GLAD-391

## Bruke siste java-versioner av bibliotek
AI-koding har tedens til å bruke gamle versjoner, fordi cutoff for treningen er noen år tilbake i tid.
Skillen _upgrade-gradle-dependencies_ sørger for at når nye bibliotek legges til, brukes siste versjon
av avhengigheten.

Installere:

```shell
mkdir -p ~/.copilot/skills/upgrade-gradle-dependencies
rsync -a --delete skills/upgrade-gradle-dependencies/ ~/.copilot/skills/upgrade-gradle-dependencies/
```

## Bruke siste versjoner av Github workflows

Installere:

```shell
mkdir -p ~/.copilot/skills/upgrade-github-workflows
rsync -a --delete skills/upgrade-github-workflows/ ~/.copilot/skills/upgrade-github-workflows/
```


## Ressurser
### OpenReWrite
https://docs.openrewrite.org

### Wildfly
https://github.com/wildfly/wildfly-server-migration
