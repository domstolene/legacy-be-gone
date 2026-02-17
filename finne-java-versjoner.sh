#!/usr/bin/env bash
# Skript for å finne ut hvilke java-versjoner som brukes i repoene våre
# Bruk:
#   ./finne-java-versjoner.sh
#   ./finne-java-versjoner.sh --no-cache  # tømmer cache før kjøring
#
# Dokumentasjon code search API:
# - https://docs.github.com/en/search-github/searching-on-github/searching-code?versionId=free-pro-team%40latest&productId=search-github&restPage=searching-on-github
# - https://docs.github.com/en/rest/search/search?apiVersion=2022-11-28#search-code
set -eo pipefail
trap catch ERR

folder=java-versjoner
org=domstolene

# java-version i actions/setup-java er nokså pålitelig og sjekkes først
search_terms=(java-version)
# vanlig i gradle prosjekter
search_terms+=(languageVersion JavaVersion sourceCompatibility targetCompatibility)
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
      echo
      continue
    fi

    # finn sannsynlig språk med languages API-et
    top_3_languages=$(get_top_3_languages "$org" "$repo")
    if [[ $top_3_languages  != *"Java,"* ]] && [[ $top_3_languages  != *"Kotlin,"* ]]; then
      echo "Hoppet over $repo, Java eller Kotlin er ikke i topp tre språk: $top_3_languages" \
        | tee "$output_file"
      echo
      continue
    fi

    # hvis filen .java-version finnes, bruker vi den
    if get_java_version_from_file "$org" "$repo" > "$output_file"; then
      cat "$output_file"
      echo
      continue
    fi

    # unngå å bruke et subshell $() her, slik at rate_limit_remaining ikke nullstilles for hver iterasjon
    if search_code "$repo" > "$output_file.temp"; then
      grep -E "($all_search_terms_grep)" "$output_file.temp" \
        | tee "$output_file"
    else
      echo "Fant ingen treff for https://github.com/$org/$repo. Topp tre språk: $top_3_languages" \
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

get_top_3_languages() {
  local org="$1" repo="$2" languages

  languages=$(gh api "/repos/$org/$repo/languages" | yq --input-format json --output-format yaml)

  if [[ $languages == "{}" ]]; then
    echo "Fant ingen språk"
    return
  fi

  echo "$languages" \
    | sed -E 's/([^:]+): ([0-9]+)$/\2 \1/' \
    | sort -nr \
    | head -n3 \
    | tr "\n" ","
}

get_java_version_from_file() {
  # forks støtter ikke kodesøk, så vi prøver å finne java-versjoner ved å se på filer i repoet først
  # dette er også raskere enn å bruke kodesøket, ettersom kodesøk-APIet har rate limit på 10 søk per minutt
  local org="$1" repo="$2" version

  if version=$(get_file_content "$org" "$repo" .java-version); then
    echo "$org/$repo:.java-version: $version"
    return
  fi

  # prøver å hente prosjektfil for gradle eller maven i roten
  local files=(build.gradle build.gradle.kts pom.xml)

  for file in "${files[@]}"; do
    if version=$(get_file_content "$org" "$repo" "$file" | grep -E "($all_search_terms_grep)"); then
      echo "$version" | sed "s|^|$org/$repo:$file: |"
      return
    fi
  done

  return 1
}

get_file_content() {
  local org="$1" repo="$2" filename=$3

  if content=$(
    gh api "/repos/$org/$repo/contents/$filename" --jq .content 2>/dev/null \
    | base64 --decode 2>/dev/null
  ); then
    echo "$content"
  else
    return 1
  fi
}

search_code() {
  local repo="$1" result

  # API-et støtter ikke OR, så derfor må vi gjøre søkene hver for seg.
  # Søk på web derimot støtter OR, som er forvirrende.
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

catch() {
  echo "En feil oppsto, sjekk DEBUG=1 $0 --no-cache for mer info" >&2
  exit 1
}

main "$@"
