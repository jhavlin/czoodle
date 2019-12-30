module Common.CommonUtils exposing
    ( normalizeStringMaybe
    , stringToMaybe
    )


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


normalizeStringMaybe : Maybe String -> Maybe String
normalizeStringMaybe strOpt =
    strOpt
        |> Maybe.map String.trim
        |> Maybe.andThen
            (\s ->
                if String.isEmpty s then
                    Nothing

                else
                    Just s
            )
