module Poll.YesNoPoll.YesNoPollData exposing (..)


type YesNoOption
    = Yes
    | No
    | IfNeeded
    | Maybe
    | Unset


type alias YesNoPollSettings =
    { allowIfNeeded : Bool
    , allowMaybe : Bool
    }
