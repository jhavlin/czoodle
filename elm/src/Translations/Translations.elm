module Translations.Translations exposing (available, default, get)

import Common.ListUtils exposing (findFirst)
import Translations.Translation exposing (Translation)
import Translations.TranslationCz exposing (translationCz)
import Translations.TranslationEn exposing (translationEn)


available : List Translation
available =
    [ translationCz
    , translationEn
    ]



-- Get translation by code


get : String -> Translation
get code =
    Maybe.withDefault default <| findFirst (\i -> i.code == code) available


default : Translation
default =
    translationEn
