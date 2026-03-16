---
name: upgrade-gradle-dependencies
description: Upgrades any java dependencies in a Gradle project to the latest version.
---

To upgrade Java dependencies in a Gradle project to the latest version, follow these steps:

1. Read latest versions from `gradle/libs.versions.toml`, `build.gradle.kts` or `build.gradle`.
2. Find latest version of the dependency:
  1. Go to https://repo.maven.apache.org/maven2/<groupId>/<artifactId>/ and check the latest version number.
     Example: org.mockito:mockito-core -> https://repo.maven.apache.org/maven2/org/mockito/mockito-core/
  2. Find latest version of the dependency using command line:

     ```shell
     curl https://repo.maven.apache.org/maven2/org/mockito/mockito-core/ --silent | grep "a href" | grep -v "maven-metadata" | sed -E 's|.*href="([^"]+)".*|\1|g' | sort -rV | head -n3
     ```

     This will show you the latest 3 versions of the dependency, and you can choose the latest one from the list.

3. Upgrade the dependency in `gradle/libs.versions.toml`, `build.gradle.kts` or `build.gradle` file, using the latest version found in the previous step.
4. Run `./gradlew build` to ensure that the project compiles with the new dependency.
