#!/usr/bin/env bash
set -xe

# Install local teads-central (documented @ https://confluence.teads.net/display/INFRA/teads-central+documentation)
curl -sL http://dl.teads.net/teads-central/get.sh | sh -

# Common variables
REG_URL=$(./teads-central docker dev-registry-url)

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
git remote add upstream git@github.com:ampproject/amphtml.git
git fetch upstream
git rebase upstream/master

# Build
# ghprbSourceBranch (PR branch name) is provided by Jenkins git plugin
docker build -t "${IMAGE}":"${HASH}" .

# Run
./teads-central docker run-tagged "${IMAGE}" --local

# Smoke test embedded webserver
./teads-central docker wait-for --tagged -p http -c "${IMAGE}":8000/test/manual/teads/amp-sample/index.html
