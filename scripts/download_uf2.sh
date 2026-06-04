#!/bin/bash
set -xe
# download uf2 for the pico. Use repos.yaml to detect repo and branch
# uses gh cli to download it. If fails (or not existing), then install-scripts will use a fallback
cd "$(dirname "$0")" || exit 1
cd ../ || exit 1
mkdir git_local || true
cd git_local || exit 1

if [ -f Telemetrix4RpiPico.uf2 ]; then
	echo "Telemetrix4RpiPico.uf2 already exists, skipping download"
	exit 0
fi

function download_uf2() {
	gh run list -L 1 -w "Deploy new version" -s "success" --repo $REPO --branch $BRANCH --json databaseId -q ".[0].databaseId" | xargs -I {} gh run download {} --repo $REPO --dir . --name "dist" || true
}

# read repo and branch from repos.yaml
REPO=$(yq eval '.repositories.mirte-telemetrix4rpipico.url' ../repos.yaml | sed 's/https:\/\/github.com\///' | sed 's/\.git//')
BRANCH=$(yq eval '.repositories.mirte-telemetrix4rpipico.version' ../repos.yaml)

# if branch is not found, use main
if [ -z "$BRANCH" ]; then
	BRANCH=main
fi

ORIG_REPO=$REPO
# get last run from the current branch, if not found, try to get from main branch, if still not found, fail.
download_uf2

# if not found, try to get from main branch
if [ ! -f Telemetrix4RpiPico.uf2 ]; then
	echo "No uf2 found for branch $BRANCH, trying to download from main branch"
	BRANCH=main
	download_uf2
	echo "Downloaded Telemetrix4RpiPico.uf2 from main branch"
fi
if [ ! -f Telemetrix4RpiPico.uf2 ]; then
	echo "Failed to download Telemetrix4RpiPico.uf2 from both branch $BRANCH and main branch, using mirte-robot"
	REPO=mirte-robot/mirte-telemetrix4rpipico
	BRANCH=main
	download_uf2
fi
if [ ! -f Telemetrix4RpiPico.uf2 ]; then
	echo "failed to download from action, trying release"
	gh release download --clobber -D . --pattern "*" --repo $ORIG_REPO || true
fi
if [ ! -f Telemetrix4RpiPico.uf2 ]; then
	echo "trying from mirte-robot/mirte-telemetrix4rpipico release"
	gh release download --clobber -D . --pattern "*" --repo mirte-robot/mirte-telemetrix4rpipico || true
fi
if [ ! -f Telemetrix4RpiPico.uf2 ]; then
	echo "Failed to download Telemetrix4RpiPico.uf2 from actions and releases, also mirte-robot, please check the repository $ORIG_REPO for the latest build and upload it to the releases if not already there."
	exit 1
fi
