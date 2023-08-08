#!/bin/bash 
git submodule foreach "br=$(git remote show origin | grep 'HEAD branch' | cut -d' ' -f5); git fetch --depth 1 origin $br; git reset -q --hard FETCH_HEAD"
if ! git diff-index --quiet HEAD; then
   git commit -am "Daily update: $(date +'%d-%m-%Y')" && git push 
fi
