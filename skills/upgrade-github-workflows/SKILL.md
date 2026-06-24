---
name: upgrade-github-workflows
description: Upgrade GitHub workflows to use latest versions of actions and tools.
---

To upgrade GitHub workflows to use the latest versions of actions and tools, follow these steps:

1. Use user submitted workflow or list all Github workflows in the repository by running the following command in the terminal:

   ```shell
   fd --type f --glob '*.y*ml' .github/workflows/
   ```

   If no workflows are found, ask user to provide one or multiple workflows to upgrade.

2. For each workflow file, find all actions used in the workflow by looking for lines that contain `uses:`, and extract the action name and version. You can use the following command to do this:

   ```shell
   rg "uses:" .github/workflows/ | sed -E 's|.*uses:\s*([^@]+)@([^ ]+).*|\1 \2|g'
   ```

   This will give you a list of actions and their versions used in the workflows.

3. For each action, check if there is a newer version available in Github relases with:

    ```shell
    curl --silent https://api.github.com/repos/<owner>/<repo>/releases/latest | jq -r .tag_name
    ```

    Replace `<owner>` and `<repo>` with the owner and repository name of the action, for example:

    ```shell
    curl --silent https://api.github.com/repos/actions/checkout/releases/latest | jq -r .tag_name | cut -d. -f1
    ```

Only major versions are relevant for this skill, so we cut the version string to only include the major version.
