---
name: configure-opentelemetry-agent
description: Configures application with da-otel-agent as a java agent and adds default configuration for the agent.
---

Konfigurasjon av sporing med da-otel-agent


## Konfigurasjon av spring i applikasjon

For å sette opp sporing for en applikasjon, gjør disse konfigurasjonsendringene:

1. Legg til agenten, start applikasjonen med den og legg til standardkonfigurasjon. Legges til i Dockerfile:

   ```Dockerfile
   # legg til agent i image
   ADD https://github.com/domstolene/da-otel-agent/releases/download/1.7.1/da-opentelemetry-javaagent.jar /app/

   # legg til oppstarts-parameter for java-agent
   # SERVICE_OPTS for gradle-bygg som bruker application plugin, alternativt JAVA_OPTS, CMD eller ENTRYPOINT
   ENV SERVICE_OTPS="-javaagent:/app/da-opentelemetry-javaagent.jar"

   # standardkonfigurasjon sporing
   RUN chmod 644 /app/da-opentelemetry-javaagent.jar && \
    echo "sampler: parentbased_traceidratio" > /app/da-opentelemetry-javaagent.yaml && \
    echo "sampleRatio: 0.01" >> /app/da-opentelemetry-javaagent.yaml && \
    echo "rules:" >> /app/da-opentelemetry-javaagent.yaml && \
    echo "  - exclude:" >> /app/da-opentelemetry-javaagent.yaml && \
    echo "      - url.path: \"/ready\"" >> /app/da-opentelemetry-javaagent.yaml && \
    echo "      - url.path: \"/metrics\"" >> /app/da-opentelemetry-javaagent.yaml

   # navn på tjenensten
   ENV OTEL_SERVICE_NAME=drl-web-api

   # skru av sending av metrikker og logger, som ikke støttes i vårt OpenTelemetry-oppsett per nå
   ENV OTEL_METRICS_EXPORTER=none
   ENV OTEL_LOGS_EXPORTER=none
   ```

   Alternativt kan samme verdier settes i en configmap som legges til containerens `envFrom`.


2. Hvor sporing skal sendes, og hvor agenten finner da-otel-agent-service for live-konfigurasjon. Legg til i kustomization.yaml:

   ```yaml
   components:
     - ../../_base/sporing
   ```

   Alternativt, dersom applikasjonen har flere deployments og/eller containers, bruk configmap direkte:

   ```yaml
   configMapGenerator:
     - name: drl-web-api-config # en configmap som er lagt til containerens envFrom
       envs:
         - config.env # konfigurasjon for tjenensten - ikke alle tjenester har denne
         - ../../_base/sporing/plain-config.yaml # felles konfigurasjon for sporing
   ```


Dette vil sette opp agenten mot en OTEL-kompatibel collector som vil samle inn 1 % av sporingsdata. I perioder kan det en justere på samlingraten og eventuelt filter for å alltid inkludere eller ekskludere sporingsdata.

!!! danger "Viktig"

    Det er viktig å tenke på samplingsraten i produksjon ettersom full innhenting vil kunne bety enorme mengder med data og høy kapasitetsbruk. For eksempel kjører Lovisa med en samplingsrate på 0.001; dvs en promille av all trafikk.


## Ytterligere dokumentasjon

Se [Prinsipper for: Logging, metrikker, sporing og probing på Confluence](https://domstol.atlassian.net/wiki/spaces/UT/pages/3867574322/Logging+metrikker+sporing+og+probing) for mer informasjon.


