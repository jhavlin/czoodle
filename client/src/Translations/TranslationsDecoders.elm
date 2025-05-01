module Translations.TranslationsDecoders exposing (decodeTranslation)

import Json.Decode as D
import List
import Translations.Translation exposing (Translation)
import Translations.Translations as Translations



-- Decode array of supported language codes as a translation record


decodeTranslation : D.Decoder Translation
decodeTranslation =
    D.map languageArrayToTranslation <| D.field "languages" (D.list D.string)


languageArrayToTranslation : List String -> Translation
languageArrayToTranslation languages =
    let
        isCzechCode code =
            code == "cs" || String.startsWith "cs-" code
    in
    if List.any isCzechCode languages then
        Translations.get "CZ"

    else
        Translations.default
