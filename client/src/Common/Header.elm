module Common.Header exposing (headerLogo)

import Html exposing (Html, h1, text)


headerLogo : Html msg
headerLogo =
    h1 [] [ text "Czoodle" ]
