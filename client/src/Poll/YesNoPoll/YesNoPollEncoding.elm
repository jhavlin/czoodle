module Poll.YesNoPoll.YesNoPollEncoding exposing (..)

import Json.Decode as D
import Poll.YesNoPoll.YesNoPollData exposing (YesNoOption(..))


decodeYesNoOption : D.Decoder YesNoOption
decodeYesNoOption =
    let
        convert s =
            case s of
                "yes" ->
                    Yes

                "no" ->
                    No

                "ifNeeded" ->
                    IfNeeded

                "maybe" ->
                    Maybe

                _ ->
                    Unset
    in
    D.map convert D.string
