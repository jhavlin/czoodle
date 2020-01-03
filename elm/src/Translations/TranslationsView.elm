module Translations.TranslationsView exposing (translationsView)

import Html exposing (Html, a, div, text)
import Html.Attributes exposing (class, title)
import Html.Events exposing (onClick)
import Translations.Translation exposing (Translation)
import Translations.Translations exposing (available)


translationsView : Translation -> (String -> msg) -> Html msg
translationsView current message =
    let
        currentClass translation =
            if translation.code == current.code then
                " translation-item-selected"

            else
                ""

        translationToItem translation =
            a
                [ class <| "translation-item" ++ currentClass translation
                , title translation.name
                , onClick <| message translation.code
                ]
                [ text translation.code ]

        items =
            List.map translationToItem available
    in
    div [ class "translation-base-line" ]
        [ div [ class "translation-list" ]
            items
        ]
