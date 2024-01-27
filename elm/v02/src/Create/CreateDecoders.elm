module Create.CreateDecoders exposing (decodeCreateFlags)

import Common.CommonDecoders exposing (decodeDay)
import Json.Decode exposing (Decoder, andThen, fail, field, map3, string, succeed)
import SDate.SDate exposing (SDay)
import Translations.Translation exposing (Translation)
import Translations.TranslationsDecoders exposing (decodeTranslation)


decodeCreateFlags : Decoder { today : SDay, baseUrl : String, translation : Translation }
decodeCreateFlags =
    let
        topDecoder =
            field "today" decodeDay

        checker maybeSDay =
            case maybeSDay of
                Just sDay ->
                    succeed sDay

                Nothing ->
                    fail "Expected some valid today value"

        checkingDecoder =
            andThen checker topDecoder

        mapper sDay baseUrl translation =
            { today = sDay, baseUrl = baseUrl, translation = translation }
    in
    map3 mapper checkingDecoder (field "baseUrl" string) decodeTranslation
