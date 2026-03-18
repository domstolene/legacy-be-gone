# legacy be gone
Automasjoner for å oppgradere applikasjoner, slik som java-oppdateringer og oppdateringer av rammeverk.

## Oversikt
Se [java-versjoner.md](java-versjoner.md) for oversikten.

[finne-java-versjoner.sh](finne-java-versjoner.sh) finner hvilke java-versjoner som er i bruk i repoene
via githubs API og fuzzy find. Resultatet brukes i [lage-oversikt-versjoner.sh](lage-oversikt-versjoner.sh) for å opprette [java-versjoner.md](java-versjoner.md).

## Skills
Det er skrevet flere [agent skills](https://agentskills.io/) for håndtere kodearbeidet med java-oppgraderinger, mm.

### Installere
Installere alle skills:

```shell
./skills/install.sh
```

### Hvordan bruke?

1. Åpne [Copilot CLI](https://github.com/features/copilot/cli) i et repo:

   ```shell
   cd et/java/repo
   copilot
   ```

2. Be agenten om å oppgradere Java:

   > ugprade java

Når instruksen er lik navn på skill vil copilot bruke instruksen i SKILL.md til å utføre oppgaven. Beskrivelsen skal også hjelpe agenten å ta i bruk en skill, altså er bruk av skill ikke deterministisk, men fuzzy.

Dersom skill krever input fra deg, og du ønsker kjøre agenten i bakgrunnen, kan du gi input som tekst direkte i instruksen:

```shell
copilot -p "upgrade java, case number is GLAD-391" --yolo # yolo på egen risiko
```

Dersom utfallet er dårlig, rediger eller legg til nye steg som trengs i eksempelvis [upgrade-java/SKILL.md](skills/upgrade-java/SKILL.md).

### Java-oppgradering

[upgrade-java](skills/upgrade-java/SKILL.md) gjør en full oppgradering til siste JDK versjon av Java for en applikasjon.


### Maven -> Gradle migrasjon

[migrate-to-gradle](skills/migrate-to-gradle/SKILL.md) legger til gradle som byggeverktøy for en applikasjon.


### Bruke siste java-versioner av bibliotek
AI-koding har tedens til å bruke gamle versjoner, fordi cutoff for treningen er noen år tilbake i tid.
For å prøve å gi agenten bedre kontekst finnes disse ferdighetene:

- [upgrade-gradle-dependencies](skills/upgrade-gradle-dependencies/)
- [use-latest-versions-for-java-library](skills/use-latest-versions-for-java-library/SKILL.md)


### Bruke siste versjoner av Github workflows

[upgrade-github-workflows](skills/upgrade-github-workflows/SKILL.md) ser gjennom alle workflows, finner siste release for de og oppgraderer workflowene.


## Nyttige lenker
### OpenReWrite
Java-oppdateringene lener seg på deterministisk migrasjon ved hjelp av https://docs.openrewrite.org.

### Wildfly
Idé for senere, se på automatisk migrasjon av Wildfly: https://github.com/wildfly/wildfly-server-migration
