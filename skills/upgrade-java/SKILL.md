---
name: upgrade-java
description: Upgrade Java to the latest LTS version.
---

To upgrade Java to the latest LTS version, follow these steps:

1. [Find latest Java LTS version](find-latest-java-lts-version.md).
2. [Check if project is using Gradle or Maven](find-java-build-tool.md).
3. [Find latest Gradle version](find-latest-gradle-version.md).
4. If kotlin is used, kotlin might need upgrade too: [Find latest Kotlin version](find-latest-kotlin-version.md).
5. [Find OpenRewrite instructions for the spesific Gradle version](find-openrewrite-gradle-migration-instructions.md)
6. In root of repo, create a file named gradle-migration-instructions.md and copy the Gradle instructions for the specific Java version into it.
7. Do steps in gradle-migration-instructions.md.
8. Make sure project compiles with `./gradlew build`, fix any errors.
9. Ask user for review, pause migration until user confirms.
10. Commit changes.
11. [Find OpenRewrite instructions for the spesific Java version](find-openrewrite-java-migration-instructions.md)
12. In root of repo, create a file named java-migration-instructions.md and copy the OpenRewrite instructions for the specific Java version and build tool into it.
13. Do steps in java-migration-instructions.md.
14. Make sure project compiles with `./gradlew build`, fix any errors.
15. Ask user for review, pause migration until user confirms.
16. Commit changes.
