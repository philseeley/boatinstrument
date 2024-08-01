#!/usr/bin/env bash

# generate personal github token
# and set it as GITHUB_TOKEN environment variable in your circleCI project settings

echo "Publishing to github release"

set -x

FILE=$(ls packages/*.tgz)
echo curl -X POST \
    -H '"Content-Length: '$(stat --format=%s $FILE)'"' \
    -H '"Content-Type: '$(file -b --mime-type $FILE)'"' \
    -T '"'$FILE'"' \
    -H '"Authorization: token '$GITHUB_TOKEN'"' \
    -H '"Accept: application/vnd.github.v3+json"' \
    '"https://uploads.github.com/repos/bareboat-necessities/lysmarine_gen/releases/54202060/assets?name='$(basename $FILE)'"' >> upload.command

# TODO:
#`upload.command` 
