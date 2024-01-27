module Data.DataDecoders exposing
    ( decodeComment
    , decodePersonRow
    , decodePoll
    , decodePollInfo
    , decodeProject
    , decodeSelectedOption
    )

import Common.CommonDecoders exposing (decodeDay)
import Common.CommonUtils exposing (stringToMaybe)
import Data.DataModel
    exposing
        ( Comment
        , CommentId(..)
        , DateOptionItem
        , GenericOptionItem
        , OptionId(..)
        , PersonId(..)
        , PersonRow
        , Poll
        , PollId(..)
        , PollInfo(..)
        , Project
        , SelectedOption(..)
        )
import Dict exposing (Dict)
import Json.Decode as D


decodePollInfo : D.Decoder PollInfo
decodePollInfo =
    let
        strictDayDecoder =
            let
                beStrict maybeSDay =
                    case maybeSDay of
                        Just sDay ->
                            D.succeed sDay

                        Nothing ->
                            D.fail "invalid day encountered"
            in
            D.andThen beStrict decodeDay

        decodeDayItem =
            D.map3 DateOptionItem
                (D.map OptionId <| D.field "id" D.int)
                (D.field "value" strictDayDecoder)
                (D.map (Maybe.withDefault False) <| (D.maybe <| D.field "hidden" D.bool))

        decodeStringItem =
            D.map3 GenericOptionItem
                (D.map OptionId <| D.field "id" D.int)
                (D.field "value" D.string)
                (D.map (Maybe.withDefault False) <| (D.maybe <| D.field "hidden" D.bool))

        datePollInfoDecoder =
            D.map (\l -> DatePollInfo { items = l }) <|
                D.field "items" (D.list decodeDayItem)

        genericPollInfoDecoder =
            D.map (\l -> GenericPollInfo { items = l }) <|
                D.field "items" (D.list decodeStringItem)

        choose type_ =
            case type_ of
                "date" ->
                    datePollInfoDecoder

                "generic" ->
                    genericPollInfoDecoder

                _ ->
                    genericPollInfoDecoder
    in
    D.andThen choose <| D.field "type" D.string


decodeSelectedOption : D.Decoder SelectedOption
decodeSelectedOption =
    let
        convert s =
            case s of
                "yes" ->
                    Yes

                "ifNeeded" ->
                    IfNeeded

                _ ->
                    No
    in
    D.map convert D.string


decodePersonRow : D.Decoder PersonRow
decodePersonRow =
    let
        pairsDecoder : D.Decoder (List ( String, SelectedOption ))
        pairsDecoder =
            D.keyValuePairs decodeSelectedOption

        foldFn : ( String, SelectedOption ) -> Maybe (Dict Int SelectedOption) -> Maybe (Dict Int SelectedOption)
        foldFn ( strKey, value ) acc =
            Maybe.map2 (\int dict -> Dict.insert int value dict) (String.toInt strKey) acc

        pairsToDict : List ( String, SelectedOption ) -> D.Decoder (Dict Int SelectedOption)
        pairsToDict pairs =
            let
                dictionary : Maybe (Dict Int SelectedOption)
                dictionary =
                    List.foldl foldFn (Just Dict.empty) pairs
            in
            case dictionary of
                Just d ->
                    D.succeed d

                Nothing ->
                    D.fail "all option keys have to be convertible to integers"

        votesDictDecoder : D.Decoder (Dict Int SelectedOption)
        votesDictDecoder =
            D.andThen pairsToDict pairsDecoder
    in
    D.map3 PersonRow
        (D.map PersonId <| D.field "id" D.int)
        (D.field "name" D.string)
        (D.field "options" votesDictDecoder)


decodePoll : D.Decoder Poll
decodePoll =
    D.map6 Poll
        (D.map PollId <| D.field "id" D.int)
        (D.map stringToMaybe <| D.field "title" D.string)
        (D.maybe <| D.field "description" D.string)
        (D.field "def" decodePollInfo)
        (D.field "people" <| D.list decodePersonRow)
        (D.field "lastPersonId" D.int)


decodeComment : D.Decoder Comment
decodeComment =
    D.map2 Comment
        (D.map CommentId <| D.field "id" D.int)
        (D.field "text" D.string)


decodeProject : D.Value -> Result D.Error Project
decodeProject json =
    let
        projectDecoder =
            D.map5 Project
                (D.map stringToMaybe (D.field "title" <| D.string))
                (D.field "polls" <| D.list decodePoll)
                (D.field "lastPollId" D.int)
                (D.field "comments" <| D.list decodeComment)
                (D.field "lastCommentId" D.int)
    in
    D.decodeValue projectDecoder json
