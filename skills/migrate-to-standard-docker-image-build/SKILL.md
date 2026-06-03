---
name: migrate-to-standard-docker-image-build
description: Migrate project to use our standard docker image build. Uses a setup that is easy to maintain and understand, and also run locally to debug troubles.
---

To migrate a project to use our standard docker image build, follow these steps:

1. Find the Dockerfile(s) in the project: `fd "(Docker|Container)file" --type f`
2. Docker image should be built from `docker.io/eclipse-temurin:25-jre` for Java 25.
3. Use skill `configure-opentelemetry-agent` to setup telemetry.
4. Make sure the docker build copies the jar file to the image with `ADD`:

   ```Dockerfile
   ADD --chmod=644 build/libs/*.jar name-of-app.jar
   ```

5. If ENTRYPOINT is set to `java -jar`, make sure use this entrypoint:

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

   If ENTRYPOINT is using a startup script, like `ENTRYPOINT ./service` only change to using JSON-syntax `ENTRYPOINT ["./service"]`.

6. Use `gh api` to get domstolene/k8s-applications/main/applications/<applikasjonsnavn>/_base/deployment.yaml, and check if configuration is mounted somewhere else than `/app`. If so make sure `WORKDIR` in Dockerfile is set to the same path, for example:

   ```Dockerfile
   # Standard er arbeidskatalog /app, men tidligere base image vi brukte hadde
   # /deployments, og det er enklere å beholde det for å slippe å endre
   # konfigurasjon i k8s-applications.
   WORKDIR /deployments
   ```

7. If the project is using spring-boot, make sure plain.jar is not built, to avoid copying wrong jar file into docker. `build.gradle.kts`:

   ```kotlin
   // Deaktiver bygg av ip-ap-api-plain.jar, slik at vi kun bygger fat-jar som skal brukes i Docker image.
   tasks.jar {
       enabled = false
   }
   ```

8. Edit github workflows to contain the three types:
   a. CI workflow that compiles and tests the code on pull requests. [pr-compile-and-test.yaml](pr-compile-and-test.yaml).
   b. CD workflow that builds and pushes docker images on commits to main branch. [cd-build-main-docker-image.yaml](cd-build-main-docker-image.yaml).
   c. Release workflow that builds and pushes docker images on releases. [release.yaml](release.yaml).

   Make sure docker image tag is the same as they where before. For example if :latest was used, do not change til :main.

9. Make sure `build.gradle.kts` uses property `releaseVersion` to set the version of the application:

   ```kotlin
   version = project.findProperty("releaseVersion") ?: "develop"
   ```

10. Make sure the file .java-version exists and contains same version as build.gradle.kts.
11. Give feedback to user, make sure repo has access to write to image, output link to user with explaination in norwegian: https://github.com/orgs/domstolene/packages/container/<repo-name>/settings
12. Ask if user wants to continue with skill configure-automatic-rollout, which configures automatic rollout of new docker images in test environment with ArgoCD Image Updater.
