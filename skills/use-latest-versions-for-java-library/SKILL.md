---
name: use-latest-versions-for-java-library
description: Finds the latest versions of Java dependencies. Should be invoked whenerver editing or adding dependencies to pom.xml, gradle/libs.versions.toml, build.gradle.kts or build.gradle files. Should also be used when instruction are similar to "upgrade java dependencies to latest versions", "upgrade mockito library to latests versions" or "upgrade test-library to latest versions".
---

Given a Java dependency, steps here will help you find latest versions of the dependency. Whenever editing dependencies, use the latest version available, unless there is a specific reason to use an older version. This should be done whenever editing or adding to `pom.xml`, `gradle/libs.versions.toml`, `build.gradle.kts` or `build.gradle`.

1. Get dependency coordinates in format `<groupId>:<artifactId>`, for example `org.mockito:mockito-core`.
2. Find latest version of the dependency:
  1. Go to https://repo.maven.apache.org/maven2/<groupId>/<artifactId>/ and check the latest version number.
     Example: org.mockito:mockito-core -> https://repo.maven.apache.org/maven2/org/mockito/mockito-core/
  2. Find latest version of the dependency using command line:

     ```shell
     curl https://repo.maven.apache.org/maven2/org/mockito/mockito-core/ --silent | grep "a href" | grep -v "maven-metadata" | sed -E 's|.*href="([^"]+)".*|\1|g' | sort -rV
     ```

     This will show you all versions of the dependency, latest first.

3. If dependency already exists in project, try first latest major version.
4. Run `./gradlew build` or `mvn clean install` to ensure that the project compiles with the new dependency.
5. If build fails, try the next latest version, and repeat until you find a version that works. If no version works, there might be a compatibility issue with the project that needs to be investigated further.
