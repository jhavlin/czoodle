module Decoders exposing (decodeCreateFlags, decodeDay)

import Json.Decode exposing (Decoder, andThen, fail, field, int, map, map2, map3, string, succeed)
import SDate.SDate exposing (SDay, dayFromTuple)


decodeDay : Decoder (Maybe SDay)
decodeDay =
    map3
        (\y m d -> dayFromTuple ( y, m, d ))
        (field "year" int)
        (field "month" int)
        (field "day" int)


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
