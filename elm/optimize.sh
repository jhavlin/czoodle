#!/bin/bash
elm make --optimize src/CreateProject.elm --output ../static/js/createproject.elm.js
elm make --optimize src/Vote.elm --output ../static/v01/js/vote.elm.js
