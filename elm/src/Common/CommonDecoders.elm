module Common.CommonDecoders exposing (decodeDay)

import Json.Decode exposing (Decoder, andThen, fail, field, int, map, map2, map3, string, succeed)
import SDate.SDate exposing (SDay, dayFromTuple)


decodeDay : Decoder (Maybe SDay)
decodeDay =
    map3
        (\y m d -> dayFromTuple ( y, m, d ))
        (field "year" int)
        (field "month" int)
        (field "day" int)
