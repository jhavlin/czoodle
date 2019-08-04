#!/bin/bash
inotifywait -m ./src --format '%w%f' -e modify |
    while read file; do
        echo $file
        #   elm-format --yes src/
        elm make src/CreateProject.elm --output ../static/js/createproject.elm.js
        elm make src/Vote.elm --output ../static/v01/js/vote.elm.js
    done
