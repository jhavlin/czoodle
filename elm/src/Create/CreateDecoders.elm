module Create.CreateDecoders exposing (decodeCreateFlags)

import Common.CommonDecoders exposing (decodeDay)
import Json.Decode exposing (Decoder, andThen, fail, field, map2, string, succeed)
import SDate.SDate exposing (SDay)


decodeCreateFlags : Decoder { today : SDay, baseUrl : String }
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

        mapper sDay baseUrl =
            { today = sDay, baseUrl = baseUrl }
    in
    map2 mapper checkingDecoder (field "baseUrl" string)
