#!/bin/bash
elm make --optimize src/CreatePage.elm --output ../static/js/create.elm.js
elm make --optimize src/VotePage.elm --output ../static/v01/js/vote.elm.js
