module Data.DataEncoders exposing (encodeProject, encodeProjectAndKeys, withLast)

import Common.CommonEncoders exposing (encodeDayTuple)
import Data.DataModel
    exposing
        ( Comment
        , DateOptionItem
        , GenericOptionItem
        , Keys
        , PersonRow
        , Poll
        , PollInfo(..)
        , Project
        , SelectedOption(..)
        , commentIdInt
        , optionIdInt
        , personIdInt
        , pollIdInt
        )
import Dict exposing (Dict)
import Json.Encode as E
import SDate.SDate exposing (dayToTuple)


{-| Map value of last item of a list.
-}
withLast : (a -> b) -> b -> List a -> b
withLast fn default list =
    List.foldl (\item _ -> fn item) default list


encodeProject : Project -> E.Value
encodeProject project =
    let
        encodeGenericItem : GenericOptionItem -> E.Value
        encodeGenericItem item =
            E.object
                ([ ( "id", E.int <| optionIdInt item.optionId )
                 , ( "value", E.string item.value )
                 ]
                    ++ (if item.hidden then
                            [ ( "hidden", E.bool True ) ]

                        else
                            []
                       )
                )

        encodeDateItem : DateOptionItem -> E.Value
        encodeDateItem item =
            E.object
                ([ ( "id", E.int <| optionIdInt item.optionId )
                 , ( "value", encodeDayTuple <| dayToTuple item.value )
                 ]
                    ++ (if item.hidden then
                            [ ( "hidden", E.bool True ) ]

                        else
                            []
                       )
                )

        encodePollInfo : PollInfo -> E.Value
        encodePollInfo info =
            case info of
                GenericPollInfo { items } ->
                    E.object
                        [ ( "type", E.string "generic" )
                        , ( "items", E.list encodeGenericItem items )
                        , ( "lastItemId", E.int <| withLast (\i -> optionIdInt i.optionId) 0 items )
                        ]

                DatePollInfo { items } ->
                    E.object
                        [ ( "type", E.string "date" )
                        , ( "items", E.list encodeDateItem items )
                        , ( "lastItemId", E.int <| withLast (\i -> optionIdInt i.optionId) 0 items )
                        ]

        selectedOptionToString selectedOption =
            case selectedOption of
                Yes ->
                    "yes"

                No ->
                    "no"

                IfNeeded ->
                    "ifNeeded"

        encodeSelectedOptions : Dict Int SelectedOption -> E.Value
        encodeSelectedOptions selectedOptions =
            E.dict String.fromInt (\v -> selectedOptionToString v |> E.string) selectedOptions

        encodePersonRow : PersonRow -> E.Value
        encodePersonRow personRow =
            E.object
                [ ( "id", E.int <| personIdInt personRow.personId )
                , ( "name", E.string personRow.name )
                , ( "options", encodeSelectedOptions personRow.selectedOptions )
                ]

        descriptionToFieldEncoder : Maybe String -> List ( String, E.Value )
        descriptionToFieldEncoder description =
            case description of
                Nothing ->
                    []

                Just desc ->
                    [ ( "description", E.string desc ) ]

        encodePoll : Poll -> E.Value
        encodePoll { pollId, title, description, pollInfo, personRows, lastPersonId } =
            E.object
                ([ ( "title", E.string <| Maybe.withDefault "" title )
                 , ( "def", encodePollInfo pollInfo )
                 , ( "id", E.int <| pollIdInt pollId )
                 , ( "lastPersonId", E.int lastPersonId )
                 , ( "people", E.list encodePersonRow personRows )
                 ]
                    ++ descriptionToFieldEncoder description
                )

        encodeComment : Comment -> E.Value
        encodeComment comment =
            E.object
                [ ( "id", E.int <| commentIdInt comment.commentId )
                , ( "text", E.string comment.text )
                ]
    in
    E.object
        [ ( "title", E.string <| Maybe.withDefault "" project.title )
        , ( "polls", E.list encodePoll project.polls )
        , ( "lastPollId", E.int project.lastPollId )
        , ( "comments", E.list encodeComment project.comments )
        , ( "lastCommentId", E.int project.lastCommentId )
        ]


encodeProjectAndKeys : Project -> Keys -> E.Value
encodeProjectAndKeys project keys =
    E.object
        [ ( "project", encodeProject project )
        , ( "projectKey", E.string keys.projectKey )
        , ( "secretKey", E.string keys.secretKey )
        ]
