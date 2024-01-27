#!/bin/bash
inotifywait -m -r ./src --format '%w%f' -e modify |
    while read file; do
        echo "> Changes detected >>>>"
        echo $file
        #   elm-format --yes src/
        elm make src/CreatePage.elm --output ../../static/v01/js/create.elm.js
        elm make src/VotePage.elm --output ../../static/v01/js/vote.elm.js
    done
