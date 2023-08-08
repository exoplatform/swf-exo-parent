#!/bin/bash

##################################
export EXO_ORGANIZATIONS="Meeds-io exodev exo-addons exoplatform exo-samples exo-docker"
##################################

export SSH_MODULES=""
get_org_repositories() {
    local ORG_NAME="$1"
    local REPO_URL="/orgs/${ORG_NAME}/repos?page="
    local COUNTER=1
    while true; do
        local result=$(gh api ${REPO_URL}${COUNTER} | jq -r '.[]| select(.archived==false and .disabled==false)| .ssh_url' | xargs)
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
    git submodule add $1 $org/$repo 2>/dev/null
}

create_submodules() {
    [ -z "$SSH_MODULES" ] && exit 1
    for i in $SSH_MODULES; do
        create_submodule $i || :
    done
}

prune_submodules(){
    list=$(git config --file .gitmodules --get-regexp path | awk '{ print $2 }' | xargs)
    for item in ${list}; do
        printf "Checking $item ... "
        if ! echo ${SSH_MODULES} | grep -qo "git@github.com:$item.git"; then
            git-delete-submodule $item &>/dev/null
            echo "Deleted"
        else 
            echo "OK"
        fi
    done
}
initalize_submodules
prune_submodules
create_submodules

