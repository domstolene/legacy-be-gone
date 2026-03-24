---
name: configure-opentelemetry-agent
description: Configures application with da-otel-agent as a java agent and adds default configuration for the agent.
---

To setup opentelemetry tracing for an application, do these steps:

1. Find the latest version of the agent:

   ```shell
   gh release view --repo domstolene/da-otel-agent --json tagName --jq .tagName
   ```

2. Find Dockerfiles for the application:

   ```shell
   fd "(Docker|Container)file" --type f
   ```

3. Add the agent to the WORKDIR. If WORKDIR is not set, add it to the same location as the .jar file. Common locations are /app or /deployments.

   ```Dockerfile
   # da-otel-agent gir oss sporing der en kan skru av/på sporingen på
   # https://otelconfig.apps.ocp.test.domstol.no uten å omstarte tjenesten
   #
   # For å teste sporing lokalt, kan du:
   # 1. starte [otel-desktop-viewer](https://github.com/CtrlSpice/otel-desktop-viewer):
   #
   #    otel-desktop-viewer
   #
   # 2. Kjøre docker imaget med disse miljøvariablene:
   #
   #    docker run -e OTEL_TRACES_SAMPLER=always_on \
   #      -e OTEL_EXPORTER_OTLP_ENDPOINT=http://host.docker.internal:4318 \
   #      -e OTEL_TRACES_EXPORTER=otlp \
   #      -e OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf \
   #      <docker-image> # for eksempel ghcr.io/domstolene/drl-web-api:latest
   #
   ADD --chmod=644 https://github.com/domstolene/da-otel-agent/releases/download/<versionsnummer>/da-opentelemetry-javaagent.jar da-opentelemetry-javaagent.jar
   ```

4. Add standard configuration:

   ```Dockerfile
   # standardkonfigurasjon for sporing, slås på med OTEL_TRACES_SAMPLER=dynamic i kjøremiljøet
   RUN echo "sampler: parentbased_traceidratio" > da-opentelemetry-javaagent.yaml && \
    echo "sampleRatio: 0.01" >> da-opentelemetry-javaagent.yaml && \
    echo "rules:" >> da-opentelemetry-javaagent.yaml && \
    echo "  - exclude:" >> da-opentelemetry-javaagent.yaml && \
    echo "      - url.path: \"/ready\"" >> da-opentelemetry-javaagent.yaml && \
    echo "      - url.path: \"/metrics\"" >> da-opentelemetry-javaagent.yaml
    echo "      - url.path: \"/actuator/health\"" >> da-opentelemetry-javaagent.yaml && \
    echo "      - url.path: \"/actuator/prometheus\"" >> da-opentelemetry-javaagent.yaml

   # skru av sending av metrikker og logger, som ikke støttes i vårt OpenTelemetry-oppsett per nå
   ENV OTEL_METRICS_EXPORTER=none
   ENV OTEL_LOGS_EXPORTER=none

   # Som standard vil vi at docker image skal fungere uten tracing.
   # OTEL_TRACES_SAMPLER settes til dynamic i kjøremiljøet, slik at
   # konfigurasjonen i da-opentelemetry-javaagent.yaml blir aktiv
   ENV OTEL_TRACES_SAMPLER=always_off
   ```

5. Add the service name for the application:

   ```Dockerfile
   # navn på tjenesten i sporingsoppsettet
   ENV OTEL_SERVICE_NAME=drl-web-api
   ```

6. Make sure agent are added to start parameters.

  1. If the .jar file is started directly with `java -jar`, make sure `JAVA_OPTS` is included in the startup, and add `-javaagent`:

     ```Dockerfile
     # Merk,
     # 1. JSON-syntax ["kommando", "arg"] gir oss kontroll over hvordan prosessen startes,
     #    der "ENTRYPOINT kommando arg" implisitt kjører 'sh -c "kommando arg"'
     # 2. Implisitt "sh -c" gjør at signaler som SIGTERM ikke sendes videre til java-prosessen,
     #    og dermed ikke trigger en ryddig nedstenging av tjenesten
     # 3. "exec" i sh-kommandoen gjør at java-prosessen erstatter sh-prosessen,
     #    og dermed får signaler som SIGTERM direkte, og kan rydde opp før nedstenging
     # 4. JAVA_OPTS kan være tom, siden den evalueres i "sh -c", og gir oss mulighet
     #    til å legge til ekstra JVM-opsjoner i kjøremiljøet uten å måtte bygge nytt docker image
     ENTRYPOINT ["/bin/sh", "-c", "exec java ${JAVA_OPTS} -javaagent:da-opentelemetry-javaagent.jar -jar name-of-app.jar"]
     ```

  2. Or, alternatively, if the application starts with `ENTRYPOINT [ "./service" ]`, add the startup parameter in `SERVICE_OPTS`:

     ```Dockerfile
     # legg til oppstarts-parameter for sporing-agenten
     ENV SERVICE_OTPS="-javaagent:/app/da-opentelemetry-javaagent.jar"
     ```

Note: Comments in Dockerfile are in Norwegian, as the target audience is developers in Domstolene.
