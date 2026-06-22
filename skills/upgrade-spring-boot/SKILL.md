---
name: upgrade-spring-boot
description: Upgrade to Spring Boot 4
---

1. Ask user for case number.
2. Checkout new branch `$casenumber-spring-boot-4-$reponame`
3. Check baseline, build application and make sure it runs: `./gradlew build` and `./gradlew bootRun`
4. If application has end to end tests, run them and make sure they pass.
5. If application does not build, start or tests fails, try to fix it. Look for hints in README.md.
   If code changes are necessary, notify user before continuing and ask if it should be commited.
   If it cannot build or run, ask user what to do.
6. Add init.gradle script:

```groovy
initscript {
    repositories {
        maven { url "https://plugins.gradle.org/m2" }
    }
    dependencies { classpath("org.openrewrite:plugin:7.34.0") }
}
rootProject {
    plugins.apply(org.openrewrite.gradle.RewritePlugin)
    dependencies {
        rewrite("org.openrewrite.recipe:rewrite-spring:6.33.0")
    }
    rewrite {
        activeRecipe("org.openrewrite.java.spring.boot4.UpgradeSpringBoot_4_0")
    setExportDatatables(true)
    }
    afterEvaluate {
        if (repositories.isEmpty()) {
            repositories {
                mavenCentral()
            }
        }
    }
}
```

3. Run script using gradle: `gradle --init-script init.gradle rewriteRun`
4. Use `curl --silent https://api.github.com/repos/spring-projects/spring-boot/releases/latest | jq -r .tag_name` to find latest spring-boot release.
5. Update build.gradle.kts to use latest versjon of spring-boot.
6. Commit work.
7. Use `use-latest-versions-for-java-library` to upgrade all dependencies.
8. Commit work.
9. Check if application still runs (compared to baseline).
10. Report back to user what have been done and result. Include commits.
