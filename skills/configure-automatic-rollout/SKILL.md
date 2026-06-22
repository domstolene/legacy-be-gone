---
name: configure-automatic-rollout
description: Konfigurerer automatisk utrulling for en applikasjon med ArgoCD Image Updater i testmiljø.
---

1. Be om saksnummer fra bruker, hvis ikke gitt.
2. Finn applikasjonsnavn fra repo `git remote -v`, hvis ikke gitt.
3. Sjekk ut k8s-applications:

```shell
cd $HOME
pushd $(fd --type d --max-depth 3 k8s-applications | head -n1)
git worktree add --checkout /tmp/k8s-applications-$applikasjonsnavn -b $saksnummer-$applikasjonsnavn-automatisk-utrulling-i-test
pushd /tmp/k8s-applications-$applikasjonsnavn
```

4. Bygg applikasjonen og sjekk hvilket image den bruker:

```shell
./build ${applikasjonsnavn} | grep "image:" | awk '{print $2}' | sort -u
```

5. Sørg for at image bruker tag `:main`, hvis ikke oppdater `newTag` i applications/$applikasjonsnavn/test/kustomization.yaml til å bruke tag `:main` for image.
6. Sjekk om annotasjon for image eksisterer i Application:

```shell
rg "$image" argocd-applications/applications/

# eventuelt om ingen treff
rg "$applikasjonsnavn" argocd-applications/applications/test
```

7. Hvis ikke, legg til annotasjonen og bruk digest på image:

```yaml
argocd-image-updater.argoproj.io/image-list: $applikasjonsnavn=ghcr.io/domstolene/$applikasjonsnavn:main
argocd-image-updater.argoproj.io/$applikasjonsnavn.update-strategy: digest
```

8. Bruk git-commit skill for å lage en commit og push til origin.
9. Opprett en PR med `gh pr create`.
10. Slett worktree og branch lokalt:

```shell
popd
git worktree remove /tmp/k8s-applications
git branch -D $saksnummer-$applikasjonsnavn-automatisk-utrulling-i-test
```

11. I applikasjonsrepoet, legg til dokumentasjon i README for deployment:

```markdown
## Leveranse
Merge til main gir nytt image `ghcr.io/domstolene/<applikasjonsnavn>:main` som rulles automatisk ut i testmiljøet. Når en er klar for akseptansetestmiljøet, lag en release:

```shell
gh release create v2.2.0 --generate-notes
```

Releasen vil starte [en workflow som produserer imaget `ghcr.io/domstolene/<applikasjonsnavn>:v2.2.0`](.github/workflows/cd-build-main-docker-image.yaml) og en pull-request i k8s-applications for å oppdatere image i akseptansetest- og produksjonsmiljø.
```

12. Sjekk ut branchen <saksnummer>-<applikasjonsnavn>-dokumenter-leveranse i applikasjonsrepoet.
13. Bruk git-commit skill for å lage en commit og push til origin.
14. Opprett en PR med `gh pr create`.

Når du er ferdig, lag en oppsummering og lenker til PR-ene.
