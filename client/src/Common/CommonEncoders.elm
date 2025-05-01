module Common.CommonEncoders exposing (encodeDayTuple)

import Json.Encode exposing (Value, int, object)


encodeDayTuple : ( Int, Int, Int ) -> Value
encodeDayTuple ( y, m, d ) =
    object
        [ ( "year", int y )
        , ( "month", int m )
        , ( "day", int d )
        ]
