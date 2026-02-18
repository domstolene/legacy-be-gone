# legacy be gone
Automasjoner for å oppgradere applikasjoner, slik som java-oppdateringer og oppdateringer av rammeverk.

## Oversikt
[finne-java-versjoner.sh](finne-java-versjoner.sh) finner hvilke java-versjoner som er i bruk i repoene
via fuzzy find.

## Java 21
1. In Visual Studio Code, install _Github Copilot app modernization - upgrade for Java_.
2. Clone relevant repo:

   ```shell
   gh clone domstolene/repo-with-old-java
   ```

3. Open repo with Visual Studio Code:

   ```shell
   code repo-with-old-java
   ```

4. Open Copilot chat and instruct it to upgrade the application:

   > upgrade java runtime to the LTS version Java 21 using java upgrade tools by invoking #generate_upgrade_plan

## Ressurser
### OpenReWrite
https://docs.openrewrite.org

### Wildfly
https://github.com/wildfly/wildfly-server-migration
