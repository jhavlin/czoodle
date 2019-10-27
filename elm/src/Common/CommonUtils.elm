module Common.CommonUtils exposing (stringToMaybe)


stringToMaybe : String -> Maybe String
stringToMaybe s =
    let
        trimmed =
            String.trim s
    in
    case trimmed of
        "" ->
            Nothing

        x ->
            Just x
