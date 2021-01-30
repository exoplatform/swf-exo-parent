#!/bin/bash 
git submodule foreach "git checkout develop 2>/dev/null || git checkout master; git pull --all --tags || :"
if ! git diff-index --quiet HEAD; then
   git commit -am "Daily update: $(date +'%d-%m-%Y')" && git push 
fi
