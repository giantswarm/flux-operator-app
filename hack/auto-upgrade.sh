#!/bin/bash

appRepository="controlplaneio-fluxcd/charts/flux-operator"

currentVersion=$(yq '.dependencies | filter(.name == "flux-operator").[0].version' ./helm/flux-operator/Chart.yaml)

ghcrToken=$(curl "https://ghcr.io/token?service=ghcr.io&scope=repository:$appRepository:pull" --silent | jq '.token' | tr -d '"')

latestVersion=$(curl "https://ghcr.io/v2/controlplaneio-fluxcd/charts/flux-operator/tags/list?last=$currentVersion" --silent \
-H "Authorization: Bearer $ghcrToken" | \
jq '.tags[] | select(.|test("^[0-9]+\\.[0-9]+\\.[0-9]+$"))' | tr -d '"' | sort -V -r | head -1)

if [[ $latestVersion == "" ]]; then
    echo "No new Flux Operator version available."
    exit 0
fi

autoUpgradeBranch="auto-upgrade-to-$latestVersion"

existsInRemote=$(git ls-remote --heads origin $autoUpgradeBranch)

if [[ $existsInRemote != "" ]]; then
    echo "Branch for auto-upgrading to this version already exists."
    exit 0
fi

git checkout -b $autoUpgradeBranch

yq -i e '(.dependencies.[] | select(.name=="flux-operator") | .version) = "'''$latestVersion'''"' ./helm/flux-operator/Chart.yaml

helm dependency update ./helm/flux-operator

git add -A
git commit -m "auto-upgrade to $latestVersion"
git push origin $autoUpgradeBranch

gh pr create --title "automated upgrade from $currentVersion to $latestVersion" \
    --body "This PR updates upstream Flux Operator Helm Chart version" \
	--base main \
    --head $autoUpgradeBranch \
    -R "giantswarm/flux-operator-app"
