---
name: migrate-to-gradle
description: Migrate Java project from Maven to Gradle.
---

Use guide at https://docs.gradle.org/current/userguide/migrating_from_maven.html to migrate project from maven to gradle.
Keep both pom.xml and build.gradle.kts files, such that installation can be verified by running both `mvn clean install` and `./gradlew build` and comparing results.

1. Use latest version of gradle: `gh release view --repo gradle/gradle --json tagName --jq .tagName`
2. Add gradle wrapper with latest version: `gradle wrapper --gradle-version <latest gradle version>`
3. Check if kotlin files are found in project: `fd .kt`. If so, application type is kotlin-application, otherwise java-application.
4. Run `gradle init --dsl kotlin --type <application type>`. Select to keep both pom.xml and build.gradle.kts files when prompted.
5. Verify that both `mvn clean install` and `./gradlew build` runs successfully and produces same results.
6. Update documentation to use gradle commands instead of maven commands. You can find documentation by searching for maven commands: `rg "mvn " --files-with-matches`. For example, update README.md to use gradle commands for build and test.
7. Search for other places where maven is mentioned: `rg maven --files-with-matches`, and update to gradle if relevant. For example, update dependabot to use gradle instead of maven.
8. Remove any maven specific configuration files that are no longer needed, for example `pom.xml`, `mvnw` and `mvnw.cmd` wrapper scripts, and `.mvn` directory.
