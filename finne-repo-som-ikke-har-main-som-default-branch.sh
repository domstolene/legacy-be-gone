#!/usr/bin/env bash
# Skript for å finne hvilke repoer i organisasjonen som ikke har main som default branch,
# slik at vi kan migrere de til å bruke main branch.
# Bruk:
#   ./finne-repo-som-ikke-har-main-som-default-branch.sh
#
# Scriptet trenger:
# - gh CLI: https://cli.github.com/
# - jq: https://github.com/jqlang/jq
#
set -eo pipefail
trap catch ERR

folder=repoer-uten-main-branch
org=domstolene

main() {
  mkdir -p "$folder"

  echo "⏳ Henter alle repoer fra GitHub..." >&2
  fetch_all_repos "$org" > "$folder/repos.json"
  total_all=$(jq '[.[] | .data.organization.repositories.nodes[]] | length' "$folder/repos.json")
  echo "✅ Hentet totalt $total_all repoer" >&2

  echo "⏳ Filtrerer ikke-arkiverte repoer..." >&2
  echo -e "repo\tdefault branch\tdescription" > "$folder/all-active-repos.txt"
  filter_active_repos < "$folder/repos.json" | tee -a "$folder/all-active-repos.txt" > /dev/null
  total=$(($(wc -l < "$folder/all-active-repos.txt") - 1))
  echo "✅ Fant $total ikke-arkiverte repoer" >&2

  echo "⏳ Filtrerer arkiverte repoer..." >&2
  echo -e "repo\tdefault branch\tdescription" > "$folder/archived-repos.txt"
  filter_archived_repos < "$folder/repos.json" | tee -a "$folder/archived-repos.txt" > /dev/null
  archived=$(($(wc -l < "$folder/archived-repos.txt") - 1))
  echo "✅ Fant $archived arkiverte repoer" >&2

  echo "⏳ Filtrerer repoer som har annen branch enn 'main' som default..." >&2
  echo -e "repo\tdefault branch\tdescription" > "$folder/repos-with-another-default-branch.txt"
  filter_repos_without_main_branch < "$folder/repos.json" | tee -a "$folder/repos-with-another-default-branch.txt" > /dev/null
  found=$(($(wc -l < "$folder/repos-with-another-default-branch.txt") - 1))

  echo "✅ Fant $found av $total repoer som ikke har 'main' som default branch"
  echo "📁 Skrev til:"
  echo "   - $folder/repos.json ($total_all repoer totalt)"
  echo "   - $folder/all-active-repos.txt ($total repoer)"
  echo "   - $folder/archived-repos.txt ($archived repoer)"
  echo "   - $folder/repos-with-another-default-branch.txt ($found repoer)"
}

fetch_all_repos() {
  local org="$1"
  # shellcheck disable=SC2016
  gh api graphql --cache 24h --paginate --slurp -f org="$org" \
    -f query='query($org: String!, $endCursor: String) {
      organization(login: $org) {
        repositories(first: 100, after: $endCursor) {
          nodes {
            name
            description
            isArchived
            defaultBranchRef {
              name
            }
          }
          pageInfo {
            hasNextPage
            endCursor
          }
        }
      }
    }
  '
}

filter_active_repos() {
  jq -r '.[] | .data.organization.repositories.nodes[] | select(.isArchived == false) | [.name, .defaultBranchRef.name, .description] | @tsv'
}

filter_archived_repos() {
  jq -r '.[] | .data.organization.repositories.nodes[] | select(.isArchived == true) | [.name, .defaultBranchRef.name, .description] | @tsv'
}

filter_repos_without_main_branch() {
  jq -r '.[] | .data.organization.repositories.nodes[] | select(.isArchived == false and .defaultBranchRef.name != "main") | [.name, .defaultBranchRef.name, .description] | @tsv'
}


if [[ $DEBUG != "" ]]; then
  set -x
fi

catch() {
  echo "En feil oppsto, sjekk DEBUG=1 $0 --no-cache for mer info" >&2
  exit 1
}

main "$@"
