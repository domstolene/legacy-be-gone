---
name: check-run-configuration
description: Check for errors or misconfigurations in run configuration, and fix them.
---

1. Find application name from repository `git remote get-url origin`: `https://github.com/domstolene/ip-varsling.git` -> application name is `ip-varsling`
2. Find image name from github workflows `grep tags .github/workflows/*.y*ml`
3. Find `k8s-applications` repository locally: `zoxide query k8s-applications`
4. Go into repository and run build: `./build <application-name> <environment>`. `<environment>` can be `test`, `at` or `prod`.
   If it fails, look for similar named applications in k8s-applications/applications/. Ask user if found application is correct.
   If you find no matches, ask user for kubernetes application name.
5. Check if configuration needs updates, based on application code. For example, are some configuration options obsolete after spring boot upgrade?
6. If the configuration needs updates, create a PR for each environment separately.
7. Ask user if we should run skill `configure-automatic-rollout`.
