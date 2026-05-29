---
name: oppdatere-readme
description: Legger til relevant dokumentasjon for applikasjoner i domstolene. Finner og kobler relevante dokumenter på Confluence, OpenShift, osv.
---

# Navigere i kode
Før du starter med å hente inn informasjon, sjekk om mappen .codegraph/codegraph.db finnes i repoet. Hvis ikke, kjør init: `codegraph init -i`

# Hente informasjon fra nettsteder
Informasjonen fra nettsteder krever innlogging, bruk safari mcp når du skal hente informasjon fra nettsteder, slik at jeg kan logge inn manuelt.

# Innhold i readme
En README.md skal inneholde:

- [ ] en beskrivelse av hva applikasjonen gjør
- [ ] URL til applikasjonen i testmiljø
- [ ] URL til applikasjonen i k8s-applications
- [ ] URL til applikasjonen i ArgoCD og OpenShift
- [ ] URL til playwright testrapport
- [ ] en enkel stegvis guide for å teste applikasjonen

## Hva applikasjonen gjør
Søk gjennom dokumentasjon og kode i repoet. Lag et sammendrag og skriv en kortfattet tekst som beskriver applikasjonens funksjonalitet. Ha fokus på hensikt og mål. Lenk til sentrale filer, slik som entrypoint for applikasjonen eller viktig konfigurasjon.

Legg teksten under `## Hva gjør <applikasjon>?`. Sammenfatt innholdet til en eller to setninger som legges i toppen av README.md under `# <applikasjon>`.

Dersom README.md allerede inneholder en beskrivelse, vurder om den kan forbedres eller om den er tilstrekkelig. Det er bedre å ha en god beskrivelse enn å fjerne eksisterende informasjon.


## URL til applikasjonen i testmiljø
Finn mest sannsynlige URL for applikasjonen i testmiljø ved å søke etter dens navn i https://github.com/domstolene/k8s-applications/blob/main/infrastructure/istio/test/kustomization.yaml

Dersom den ikke eksisterer der, prøv å finne Route direkte i OpenShift:

```shell
oc login https://api.ocp.test.domstol.no:6443/ --username adminek.ase
oc get route --all-namespaces | grep <applikasjonsnavn>
```

Legg URL-en under `## URL-er`.

## URL til applikasjonen i k8s-applications
Se om du finner applikasjonen i https://github.com/domstolene/k8s-applications/tree/main/applications. Bruk image-navnet for å finne applikasjonen, dersom det ikke er åpenbart ut fra navnet på mappen.

Eksempel URL for applikasjonen 'aktorportalen': https://github.com/domstolene/k8s-applications/tree/main/applications/aktorportalen

Legg URL-en under `## URL-er`.

## URL til applikasjonen i ArgoCD og OpenShift
Bruk navnet fra k8s-applications til å legge til en URL for applikasjonen i ArgoCD og OpenShift.

Eksempel URL for applikasjonen 'aktorportalen':
- https://argocd.apps.ocp.test.domstol.no/applications/aktorportalen
- https://console.apps.ocp.test.domstol.no/k8s/ns/aktorportalen/core~v1~Pod

## URL til playwright testrapport
Finn ut som applikasjonen har en testrapport her: https://redesigned-adventure-mzqyzj5.pages.github.io/e2e-rapport/

Søk etter applikasjonens navn. Legg URL-en under `## URL-er`.

## Stegvis guide for å teste applikasjonen
Start ved å søke etter applikasjonen i tjenestekatalogen: https://domstol.atlassian.net/wiki/search?text=<applikasjon>&product=confluence&spaces=TJENESTEKAT

Se om testbeskrivelse finnes der. Hvis ikke, se om du finner noe i repoet. Gjør så en analyse av koden for å finne ut hva den gjør. Bruk codegraph for å navigere koden.

Dersom testbeskrivelse du har funnet ikke stemmer overens med koden, gi meg beskjed i svaret ditt.

Lagre testbeskrivelsen under `## Hvordan teste?`.
