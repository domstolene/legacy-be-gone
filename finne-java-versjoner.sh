#!/usr/bin/env bash
# Skript for å finne ut hvilke java-versjoner som brukes i repoene våre
# Bruk:
#   ./finne-java-versjoner.sh
#   ./finne-java-versjoner.sh --no-cache  # tømmer cache før kjøring
set -eo pipefail

folder=java-versjoner
org=domstolene

# java-version i actions/setup-java er nokså pålitelig og sjekkes først
search_terms=(java-version)
# vanlig i gradle prosjekter
search_terms+=(languageVersion)
# vanlig i maven pom.xml
search_terms+=(jvmTarget maven.compiler.source maven.compiler.target)

all_search_terms_grep=$(IFS='|'; echo "${search_terms[*]}")

main() {
  mkdir -p "$folder"
  if [[ $1 == "--no-cache" ]]; then
    rm -f "$folder"/*
  fi

  repoer=$(hent_repoer)

  for repo in $repoer; do
    echo "### $repo ###"

    output_file="$folder/$repo.txt"

    if [[ -f "$output_file" ]]; then
      cat "$output_file"
    # unngå å bruke et subshell $() her, slik at rate_limit_remaining ikke nullstilles for hver iterasjon
    elif search_code "$repo" > "$output_file.temp"; then
      grep -E "($all_search_terms_grep)" "$output_file.temp" \
        | tee "$output_file"
    else
      echo "Fant ingen treff for $repo" \
        | tee "$output_file"
    fi
    rm -f "$output_file.temp" &>/dev/null
    echo
  done
}

hent_repoer() {
  if [[ -f "$folder/repoer" ]]; then
    cat "$folder/repoer"
    return
  fi

  gh repo list $org --no-archived --limit 500 --json name --jq .[].name \
    | tee "$folder/repoer"
}

search_code() {
  local repo="$1" result

  for term in "${search_terms[@]}"; do
    rate_limit

    if result=$(gh search code "$term repo:$org/$repo"); then
      if [[ -n "$result" ]]; then
        # nøyer oss med ett resultat
        break
      fi
    else
      # oops, sannsynligvis rate limit, burde ikke skje
      echo "Søket feilet, prøv DEBUG=1 $0 --no-cache for mer info" >&2
      exit 1
    fi
  done


  if [[ -z "$result" ]]; then
    return 1
  else
    echo "$result"
  fi
}

rate_limit_remaining=$(gh api /rate_limit --jq .resources.code_search.remaining)
rate_limit() {
  # venter til vi får lov å kalle search/code igjen
  # maks 10 søk per minutt, https://docs.github.com/en/rest/search/search
  rate_limit_remaining=$((rate_limit_remaining - 1))

  if ((rate_limit_remaining <= 0)); then
    echo -n "Rate limit nådd, venter på reset" >&2
    while ((rate_limit_remaining <= 0)); do
      echo -n "." >&2
      sleep 1
      rate_limit_remaining=$(gh api /rate_limit --jq .resources.code_search.remaining)

      # noen ganger rapporterer github feil, og vi får 1 som svar når vi har nådd grensen
      # vi stoler derfor på vår egen teller mer enn githubs
      if ((rate_limit_remaining <= 1)); then
        rate_limit_remaining=0
      fi

    done
    echo

    # har nå mer enn 0 igjen, men må trekke fra kallet som skal gjøres nå
    rate_limit_remaining=$((rate_limit_remaining - 1))
  fi
}


if [[ $DEBUG != "" ]]; then
  set -x
fi

main "$@"
