#!/usr/bin/env bash
# Bruker output fra finne-java-versjoner.sh for å lage en fin oversikt i markdown.
#
# Bruk:
#   ./lage-oversikt-versjoner.sh [apps...]
#
# Scriptet trenger:
# - gh CLI: https://cli.github.com/
#
# Input
# java-versjoner/Lovisa.txt:
#   domstolene/Lovisa:.java-version: 17.0
# java-versjoner/lovisa_core.txt:
#   domstolene/lovisa_core:.github/composite-actions/setup-gradle/action.yml: java-version: "17"
#   domstolene/lovisa_core:.github/workflows/update-kotlin-dependency-graph.yml: java-version: 17
#
# Output er tabell i dette formatet:
# | Repo | Java-versjon | Til versjon | Test | AT | Prod | Kommentar |
# | --- | --- | --- | --- | --- | --- | --- |
# | [Lovisa](https://github.com/domstolene/Lovisa) | [17](https://github.com/domstolene/Lovisa/blob/develop/.java-version) | | | | | | |
# | [lovisa_core](https://github.com/domstolene/lovisa_core) | [17](https://github.com/domstolene/lovisa_core/blob/main/.github/composite-actions/setup-gradle/action.yml), [17](https://github.com/domstolene/lovisa_core/blob/main/.github/workflows/update-kotlin-dependency-graph.yml) | | | | | | |
# | [ip-folkeregister-soek](https://github.com/domstolene/ip-folkeregister-soek) | [1.8](https://github.com/domstolene/ip-folkeregister-soek/blob/develop/pom.xml) | | | | | | |
set -eo pipefail

org=domstolene
output_file="java-versjoner.md"
template="| Repo | Java-versjon | Til versjon | Test | AT | Prod | Kommentar |
| --- | --- | --- | --- | --- | --- | --- |"

main() {
  write_table_header

  # dersom ingen argumenter er gitt, bruker vi all repoer i java-versjoner-mappen
  if [ "$#" -eq 0 ]; then
    repos=$(alle_repoer)
  else
    repos="$@"
  fi

  for repo in $repos; do
    process_repo "$repo"
  done
}

write_table_header() {
  echo "$template" > "$output_file"
}

alle_repoer() {
  find java-versjoner -type f -name "*.txt" \
    | xargs grep -vE "^(Hoppet over|Fant ingen treff)" \
    | cut -d: -f1 \
    | xargs basename -s .txt \
    | sort -u
}

process_repo() {
  local repo="$1"
  local input_file="java-versjoner/${repo}.txt"

  if [ ! -f "$input_file" ]; then
    echo "Ingen data for $repo." >&2
    exit 1
  fi

  echo "Legger til $repo i oversikten..." >&2
  local versions=$(extract_versions "$input_file" "$repo")
  local repo_link="[${repo}](https://github.com/$org/${repo})"
  echo "| ${repo_link} | ${versions} | | | | | | |" >> "$output_file"
}

extract_versions() {
  local input_file="$1"
  local repo="$2"
  local branch=$(determine_branch "$repo")
  local versions=""
  local seen_paths=""

  while IFS= read -r line; do
    local file_path=$(extract_file_path "$line")
    if echo "$seen_paths" | grep -qF "$file_path"; then
      continue
    fi
    seen_paths="$seen_paths $file_path"
    versions=$(append_version "$versions" "$line" "$repo" "$branch")
  done < "$input_file"

  echo "$versions"
}

determine_branch() {
  local repo="$1"
  gh repo view "$org/$repo" --json defaultBranchRef --jq .defaultBranchRef.name
}

append_version() {
  local versions="$1"
  local line="$2"
  local repo="$3"
  local branch="$4"

  local file_path=$(extract_file_path "$line")
  local version=$(extract_version_number "$line")
  local version_link="[$version](https://github.com/$org/${repo}/blob/${branch}/${file_path})"

  if [ -z "$versions" ]; then
    echo "$version_link"
  else
    echo "${versions},${version_link}"
  fi
}

extract_file_path() {
  local line="$1"
  echo "$line" | sed -E 's/^[^:]+:([^:]+):.*/\1/'
}

extract_version_number() {
  local line="$1"
  local version=$(echo "$line" | grep -oE '[0-9]+(\.[0-9]+)?' | tail -1)
  if [ -z "$version" ]; then
    echo "?"
  else
    echo "$version"
  fi
}

main "$@"
