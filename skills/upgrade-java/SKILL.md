---
name: upgrade-java
description: Upgrade Java to the latest LTS version.
---

To upgrade Java to the latest LTS version, follow these steps:

1. [Find latest Java LTS version](find-latest-java-lts-version.md).
2. Ask user which case number they want to prefix commit messages with.
3. Create and check out a new branch named <case number>-<repo-name>-java-<java version>-upgrade.
4. [Check if project is using Gradle or Maven](find-java-build-tool.md).
5. Check latest build tool version:
  1. If gradle project:
    1. [Find latest Gradle version](find-latest-gradle-version.md).
    2. Make sure latest gradle wrapper is used: `./gradlew wrapper --gradle-version <latest gradle version>`
  2. If maven project:
    1. [Find latest Maven version](find-latest-maven-version.md).
    2. Make sure latest maven wrapper is used: `mvn wrapper:wrapper -Dmaven=<latest maven version>`
6. If kotlin is used, kotlin might need upgrade too: [Find latest Kotlin version](find-latest-kotlin-version.md).
7. [Find OpenRewrite instructions for the spesific Gradle version](find-openrewrite-gradle-migration-instructions.md)
8. Do migration steps as per OpenRewrite instructions.
9. Make sure project compiles with `./gradlew build`, fix any errors. Run from where you find the gradle wrapper: `fd gradlew`
10. Commit changes.
11. [Find OpenRewrite instructions for the spesific Java version](find-openrewrite-java-migration-instructions.md)
12. Do migration steps as per OpenRewrite instructions.
13. Make sure project compiles with `./gradlew build`, fix any errors.
14. Commit changes.
15. [Upgrade Java version in containers](upgrade-java-version-in-containers.md).
16. Commit changes.
17. [Upgrade Java version in CI](upgrade-java-version-in-ci.md).
18. Commit changes.
19. Open pull request: `gh pr create --head <branch-name> --fill --title "<case number> Upgrade Java to <java version>"`
20. Check that all checks pass: `gh pr checks --watch`

