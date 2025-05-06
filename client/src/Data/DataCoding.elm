module Data.DataCoding exposing (decodeProject)

import Candidate.DateCandidate.DateCandidateCoding exposing (decodeDateCandidateItem)
import Candidate.TextCandidate.TextCandidateCoding exposing (decodeTextCandidateItem)
import Common.CommonUtils exposing (stringToMaybe)
import Data.DataModel
    exposing
        ( CandidatesInfo(..)
        , Poll
        , PollId(..)
        , PollInfo
        , Project
        , Voter
        , VotesInfo(..)
        )
import Data.VoterId exposing (VoterId(..))
import Json.Decode as D
import Json.Encode as E
import Poll.YesNoPoll.YesNoPollCoding exposing (decodeYesNoVotesInfo)


decodeCandidatesInfo : D.Decoder CandidatesInfo
decodeCandidatesInfo =
    let
        dateCandidatesInfoDecoder =
            D.map DateCandidatesInfo <|
                D.field "items" (D.list decodeDateCandidateItem)

        textCandidatesInfoDecoder =
            D.map TextCandidatesInfo <|
                D.field "items" (D.list decodeTextCandidateItem)

        choose type_ =
            case type_ of
                "date" ->
                    dateCandidatesInfoDecoder

                "text" ->
                    textCandidatesInfoDecoder

                _ ->
                    D.fail <| "Invalid 'candidates' type " ++ type_
    in
    D.andThen choose <| D.field "type" D.string


decodeVotesInfo : D.Decoder VotesInfo
decodeVotesInfo =
    let
        choose type_ =
            case type_ of
                "yesNo" ->
                    D.map YesNotVotesInfo decodeYesNoVotesInfo

                _ ->
                    D.fail <| "Invalid 'candidates' type " ++ type_
    in
    D.andThen choose <| D.field "type" D.string


decodePollInfo : D.Decoder PollInfo
decodePollInfo =
    D.map2 PollInfo
        (D.field "candidates" decodeCandidatesInfo)
        (D.field "votes" decodeVotesInfo)


decodePoll : D.Decoder Poll
decodePoll =
    D.map4 Poll
        (D.map PollId <| D.field "id" D.int)
        (D.map stringToMaybe <| D.field "title" D.string)
        (D.maybe <| D.field "description" D.string)
        (D.field "def" decodePollInfo)


decodeVoter : D.Decoder Voter
decodeVoter =
    D.map2 Voter
        (D.map VoterId <| D.field "voterId" D.int)
        (D.field "name" D.string)


decodeProject : D.Value -> Result D.Error Project
decodeProject json =
    let
        projectDecoder =
            D.map5 Project
                (D.map stringToMaybe (D.field "title" <| D.string))
                (D.field "polls" <| D.list decodePoll)
                (D.field "lastPollId" D.int)
                (D.field "voters" <| D.list decodeVoter)
                (D.field "lastVoterId" D.int)
    in
    D.decodeValue projectDecoder json


{-| Map value of last item of a list.
-}
withLast : (a -> b) -> b -> List a -> b
withLast fn default list =
    List.foldl (\item _ -> fn item) default list


encodeProject : Project -> E.Value
encodeProject project =
    let
        encodePollInfo : PollInfo -> E.Value
        encodePollInfo info =
            case info of
                GenericPollInfo { items } ->
                    E.object
                        [ ( "type", E.string "generic" )
                        , ( "items", E.list encodeGenericItem items )
                        , ( "lastItemId", E.int <| withLast (\i -> candidateIdInt i.candidateId) 0 items )
                        ]

                DatePollInfo { items } ->
                    E.object
                        [ ( "type", E.string "date" )
                        , ( "items", E.list encodeDateItem items )
                        , ( "lastItemId", E.int <| withLast (\i -> candidateIdInt i.candidateId) 0 items )
                        ]

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
