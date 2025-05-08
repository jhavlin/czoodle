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


yesNoOptionToString : YesNoOption -> String
yesNoOptionToString yesNoOption =
    case yesNoOption of
        Yes ->
            "yes"

        No ->
            "no"

        IfNeeded ->
            "ifNeeded"

        Maybe ->
            "maybe"

        Unset ->
            "unset"


yesNoOptionFromString : String -> YesNoOption
yesNoOptionFromString string =
    case string of
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


defaultYesNoPollSettings : YesNoPollSettings
defaultYesNoPollSettings =
    { allowIfNeeded = True
    , allowMaybe = False
    }
