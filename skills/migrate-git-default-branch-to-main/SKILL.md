---
name: migrate-git-default-branch-to-main
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

6. Find any references to default branch, for example `develop` or `master`, in the codebase, and change them to `main`:

```shell
rg --hidden --glob '!.git' develop
```

Links should be change also, for example https://github.com/domstolene/repo-name/tree/develop/minikube -> https://github.com/domstolene/repo-name/tree/main/minikube

Exceptions: versions in gradle/maven files, like `build.gradle` or `pom.xml` should not be changed.

7. Create a branch, commit the changes and create a pull request:

```shell
git checkout -b <case number>-main-som-standard-branch
git add .
git commit -m "<case number> Change default branch to main"
gh pr create --title "<case number> main som default branch" --body "Endrer default branch til main. Alle referanser til develop/master er endret til main.

Refs: <case number>"
" --base develop
```

8. Merge pull request using admin priveleges, and delete branch after merge:

```shell
gh pr merge --admin --delete-branch
```

9. Rename default branch to main:

```shell
gh api repos/{owner}/{repo}/branches/develop/rename -f new_name=main
```

10. Write summary to console in Slack markup format, with link to PR.
