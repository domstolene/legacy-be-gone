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
6. Update documentation to use gradle commands instead of maven commands. You can find documentation by searching for maven commands: `rg "mvn "`
