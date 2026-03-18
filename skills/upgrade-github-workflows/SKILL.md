---
name: upgrade-github-workflows
description: Upgrade GitHub workflows to use latest versions of actions and tools.
---

To upgrade GitHub workflows to use the latest versions of actions and tools, follow these steps:

1. List all Github workflows in the repository by running the following command in the terminal:

   ```shell
   fd --type f --glob "*.yml" --glob "*.yaml" .github/workflows/
   ```

2. For each workflow file, find all actions used in the workflow by looking for lines that contain `uses:`, and extract the action name and version. You can use the following command to do this:

   ```shell
   rg "uses:" .github/workflows/*.yml | sed -E 's|.*uses:\s*([^@]+)@([^ ]+).*|\1 \2|g'
   ```

   This will give you a list of actions and their versions used in the workflows.

3. For each action, check if there is a newer version available in Github relases with:

    ```shell
    gh release list --repo <owner>/<repo> --limit 1 --json tagName --jq '.[0].tagName'
    ```

    Replace `<owner>` and `<repo>` with the owner and repository name of the action, for example:

    ```shell
    gh release list --repo actions/checkout --limit 1 --json tagName --jq '.[0].tagName'
    ```
