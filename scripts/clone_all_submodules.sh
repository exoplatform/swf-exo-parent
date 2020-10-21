#!/bin/bash

##################################
export GIT_TOKEN="$1"
export EXO_ORGANIZATIONS="meeds-io exodev exo-addons exoplatform exo-samples exo-docker"
##################################

export GIT_REST_URI="https://api.github.com/orgs/"
export SSH_MODULES=""
get_org_repositories() {
    local ORG_NAME="$1"
    local REPO_URL="$GIT_REST_URI$ORG_NAME/repos"
    [ -z "$GIT_TOKEN" ] || REPO_URL="${REPO_URL}?access_token=${GIT_TOKEN}"
    [ -z "$GIT_TOKEN" ] && REPO_URL="${REPO_URL}?page=" || REPO_URL="${REPO_URL}&page="
    local COUNTER=1
    while true; do
        local result=$(wget -qO- ${REPO_URL}${COUNTER} | jq '.[]| select(.archived==false and .disabled==false)| .ssh_url' | xargs)
        [ -z "$result" ] && break || SSH_MODULES="$SSH_MODULES $result"
        ((COUNTER++))
    done
}

initalize_org() {
    [ -z "$EXO_ORGANIZATIONS" ] && exit 1
    for i in $EXO_ORGANIZATIONS; do
        get_org_repositories $i
    done
}

initalize_submodules() {
    [ -z "$EXO_ORGANIZATIONS" ] && exit 1
    for i in $EXO_ORGANIZATIONS; do
        get_org_repositories $i
    done
}

create_submodule() {
    org=$(echo $1 | grep -o -P '(?<=github.com:).*(?=/)')
    repo=$(echo $1 | grep -o -P '(?<=/).*(?=.git)')
    git submodule add $1 $org/$repo
}

create_submodules() {
    [ -z "$SSH_MODULES" ] && exit 1
    for i in $SSH_MODULES; do
        create_submodule $i 
    done
}

initalize_submodules
create_submodules

