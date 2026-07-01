---
name: migrate-to-standard-docker-image-build
description: Migrate project to use our standard docker image build. Uses a setup that is easy to maintain and understand, and also run locally to debug troubles.
---

To migrate a project to use our standard docker image build, follow these steps:

1. Find the Dockerfile(s) in the project: `fd "(Docker|Container)file" --type f`
2. Docker image should be built from `ghcr.io/domstolene/jre:chiseled` for Java 25, sets applications name and copies jar to application.jar:

   ```Dockerfile
   # se github.com/domstolene/jre for detaljer om base image
   FROM ghcr.io/domstolene/jre:chiseled

   # navn på tjenesten i sporingsoppsettet
   ENV OTEL_SERVICE_NAME=<repo-or-application-name>

   # WORKDIR er /app, slik at den havner i /app/application.jar
   # men vi plukker opp konfigurasjon fra /config, /app/config og /deployments/config
   ADD --chmod=644 --chown=0:1000 build/libs/*.jar application.jar
   ```

   for example:

   ```Dockerfile
   # se github.com/domstolene/jre for detaljer om base image
   FROM ghcr.io/domstolene/jre:chiseled

   # navn på tjenesten i sporingsoppsettet
   ENV OTEL_SERVICE_NAME=ip-ap-api

   # WORKDIR er /app, slik at den havner i /app/application.jar
   # men vi plukker opp konfigurasjon fra /config, /app/config og /deployments/config
   ADD --chmod=644 --chown=0:1000 build/libs/*.jar application.jar
   ```

3. If the project is using spring-boot, make sure plain.jar is not built, to avoid copying wrong jar file into docker. `build.gradle.kts`:

   ```kotlin
   // Deaktiver bygg av ip-ap-api-plain.jar, slik at vi kun bygger fat-jar som skal brukes i Docker image.
   tasks.jar {
       enabled = false
   }
   ```

4. Edit github workflows to contain the three types:
   a. CI workflow that compiles and tests the code on pull requests. [pr-compile-and-test.yaml](pr-compile-and-test.yaml).
   b. CD workflow that builds and pushes docker images on commits to main branch. [cd-build-main-docker-image.yaml](cd-build-main-docker-image.yaml).
   c. Release workflow that builds and pushes docker images on releases. [release.yaml](release.yaml).

   Make sure docker image tag is the same as they where before. For example if :latest was used, do not change til :main.

5. Make sure `build.gradle.kts` uses property `releaseVersion` to set the version of the application:

   ```kotlin
   version = project.findProperty("releaseVersion") ?: "main"
   ```

6. Make sure the file .java-version exists and contains same version as build.gradle.kts.
7. Give feedback to user, make sure repo has access to write to image, output link to user with explaination in norwegian: https://github.com/orgs/domstolene/packages/container/<repo-name>/settings
8. Ask if user wants to continue with skill configure-automatic-rollout, which configures automatic rollout of new docker images in test environment with ArgoCD Image Updater.
