#!/usr/bin/env bash

workflows=$(rg "uses:" .github/workflows/ | sed -E 's|.*uses:\s*([^@]+)@([^ ]+).*|\1|g' | cut -d/ -f1,2 | sort -u)

stderr() {
  echo "$@" >&2
}

for workflow in $workflows; do
  if [[ $workflow == "domstolene/deploy-k8s" ]]; then
    stderr "Skipping $workflow"
    continue
  fi
  versions_found=$(rg "uses: $workflow@" .github/workflows/ | sed -E 's|.*uses:\s*([^@]+)@([^ ]+).*|\2|g' | sort -u | tr '\n' ',' | sed 's/,$//')
  new_version=$(curl --silent https://api.github.com/repos/"$workflow"/releases/latest | jq -r .tag_name | cut -d. -f1)

  if [[ $versions_found == "$new_version" ]]; then
    stderr "No upgrade needed for $workflow, already at $new_version"
    continue
  fi

  stderr "Upgrading $workflow from $versions_found to $new_version"

  # replace all occurrences of the workflow in all files
  rg -l "uses: $workflow@" .github/workflows/ | xargs gsed -i -E "s|uses: $workflow@[^ ]+|uses: $workflow@$new_version|g"
done
