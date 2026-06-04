---
name: create-e2e-test
description: Create an end-to-end test for a web application using Playwright.
---

Create an @playwright/test end-to-end test for the examples in the readme, use html and prometheus-reporter with `defineConfig`. put them in src/test/e2e. use pnpm as package manager. Set PROJECT to repo name which are needed for prometheus-reporter.

Test files should be in src/test/e2e and named <test-name>.spec.ts, for example `app.spec.ts`. the test should be runnable with `pnpm --dir src/test/e2e test`. Document this. Use --reporter=html so that test results are shown when they fail. Document --reporter=dot.

Find and copy prometheus-reporter into src/test/e2e from local filesystem: `cp (fd prometheus-reporter (zoxide query lovisa_core)) src/test/e2e/`.

Also create a github workflow for the tests, it should run with specific runner: "runs-on: workflow-runner-test". The workflow should upload html result to github pages as artifact. Output settings for github pages to user, and describe how settings should be updated.

I want a new endpoint /version that provides information about which version is running (main or release) and the git commit sha for it. The e2e workflow should wait for the correct version (git sha) to be running before Playwright runs. Add an appropriate timeout so the workflow is not stopped. The build must include the version information in the jar file.

Update gitignore file with reports and such:
```
node_modules
playwright-report
test-results
```

See [e2e.yaml](e2e.yaml) for
