#!/usr/bin/env bash
set -xe

# Install local teads-central (documented @ https://confluence.teads.net/display/INFRA/teads-central+documentation)
curl -sL http://dl.teads.net/teads-central/get.sh | sh -

cleanup () { trap '' INT; ./teads-central docker clean-tagged; }
trap cleanup EXIT TERM
trap true INT

# common changes above this line should be done upstream #
##########################################################

HASH=$(./teads-central vars hash)
IMAGE=$(./teads-central vars image)

# Make sure build dir is accessible from host
chmod g+s .

# Update from main amp html repository
# currently the result is not pushed because it will trigger the same job, infinite ci loop
git remote add upstream git@github.com:ampproject/amphtml.git || echo 'upstream already present'
git fetch upstream
git rebase upstream/main

# We are 4 commits ahead of master (HEAD~4). Here we reproduce what build-system/common/git.js does but hack the system by forcing 000 instead of 004 at the end of version to resolve master version
VERSION=$(TZ=UTC git log HEAD~4 -1 --pretty="%cd" --date=format-local:%y%m%d%H%M%S | cut -c1-10)
VERSION=$VERSION'000'

PUBLISHED=$(curl -s -o /dev/null -w "%{http_code}" https://cdn.ampproject.org/rtv/01"${VERSION}"/v0/amp-ad-0.1.js)

if [[ "$PUBLISHED" -ne 200 ]] ; then
  VERSION=$(git describe --tags `git rev-list --tags --max-count=1`)
  echo "AMP assets not already published used last tag:${VERSION}"
  PUBLISHED=$(curl -s -o /dev/null -w "%{http_code}" https://cdn.ampproject.org/rtv/01"${VERSION}"/v0/amp-ad-0.1.js)
  if [[ "$PUBLISHED" -ne 200 ]] ; then
    echo "AMP assets not already published for last tag:${VERSION}"
    exit 1
  fi
fi

git submodule init
git submodule update
git submodule foreach git pull origin master

rm -rf ./.git # remove 1GB to the docker image size
git init # need a git initialized directory for being able to run node ./build-system/task-runner/install-amp-task-runner.js in docker container

# Build
docker build --build-arg VERSION="${VERSION}" -t "${IMAGE}":"${HASH}" .
