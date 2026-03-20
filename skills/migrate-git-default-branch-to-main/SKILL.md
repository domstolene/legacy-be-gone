---
name: migrate-to-standard-docker-image-build
description: Migrate a github repository to use `main` as default branch.
---

To migrate a github repository to use `main` as default branch, follow these steps:

1. Ask which repository on form owner/repo.
2. Ask user for case number they want to prefix commit messages with. If not interactive, assume case number `chore:`
3. Check what the default branch is:

```shell
gh repo view <owner/repo> --json defaultBranchRef --jq .defaultBranchRef.name
```

4. If default branch is `main`, stop here. Do not proceed.
5. Clone repo into a temp-folder:

```shell
mktempdir=$(mktemp -d)
cd "$mktempdir" || exit
gh repo clone <owner/repo>
cd repo || exit
```

6. Create a new branch called main:

```shell
git checkout -b main
```

7. Find any references to `develop` or `master` in the codebase, and change them to `main`:

```shell
rg --hidden --glob '!.git' develop
```

Exceptions: versions in gradle/maven files, like `build.gradle` or `pom.xml` should not be changed.

8. Commit and push the changes:

```shell
git add .
git commit -m "<case number> Change default branch to main"
git push -u origin main
```

9. Change default branch in Github:

```shell
gh repo edit --default-branch main
```

10. Update remote to get new HEAD reference:

```shell
git remote set-head origin --auto
```
