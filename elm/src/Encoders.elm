module Encoders exposing (encodeDayTuple)

import Json.Encode exposing (Value, int, object)
import SDate.SDate exposing (SDay, dayToTuple)


encodeDayTuple : ( Int, Int, Int ) -> Value
encodeDayTuple ( y, m, d ) =
    object
        [ ( "year", int y )
        , ( "month", int m )
        , ( "day", int d )
        ]
