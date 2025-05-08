module Data.DataCoding exposing (decodeProject, encodeProject, encodeProjectAndKeys)

import Candidate.DateCandidate.DateCandidateCoding exposing (decodeDateCandidateItem, encodeDateCandidateItem)
import Candidate.TextCandidate.TextCandidateCoding exposing (decodeTextCandidateItem, encodeTextCandidateItem)
import Common.CommonUtils exposing (stringToMaybe)
import Data.DataModel
    exposing
        ( CandidatesInfo(..)
        , Keys
        , Poll
        , PollId(..)
        , PollInfo
        , Project
        , Voter
        , VotesInfo(..)
        , pollIdInt
        )
import Data.VoterId exposing (VoterId(..), voterIdInt)
import Json.Decode as D
import Json.Encode as E
import Poll.YesNoPoll.YesNoPollCoding exposing (decodeYesNoVotesInfo, encodeYesNoVotesInfo)


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


encodeCandidatesInfo : CandidatesInfo -> E.Value
encodeCandidatesInfo candidatesInfo =
    let
        ( type_, items ) =
            case candidatesInfo of
                DateCandidatesInfo list ->
                    ( "date", E.list encodeDateCandidateItem list )

                TextCandidatesInfo list ->
                    ( "text", E.list encodeTextCandidateItem list )
    in
    E.object
        [ ( "type", E.string type_ )
        , ( "items", items )
        ]


decodeVotesInfo : D.Decoder VotesInfo
decodeVotesInfo =
    let
        choose type_ =
            case type_ of
                "yesNo" ->
                    D.map YesNoVotesInfo decodeYesNoVotesInfo

                _ ->
                    D.fail <| "Invalid 'candidates' type " ++ type_
    in
    D.andThen choose <| D.field "type" D.string


encodeVotesInfo : VotesInfo -> E.Value
encodeVotesInfo votesInfo =
    case votesInfo of
        YesNoVotesInfo info ->
            encodeYesNoVotesInfo info


decodePollInfo : D.Decoder PollInfo
decodePollInfo =
    D.map2 PollInfo
        (D.field "candidates" decodeCandidatesInfo)
        (D.field "votes" decodeVotesInfo)


encodePollInfo : PollInfo -> E.Value
encodePollInfo pollInfo =
    E.object
        [ ( "candidates", encodeCandidatesInfo pollInfo.candidateInfo )
        , ( "votes", encodeVotesInfo pollInfo.votesInfo )
        ]


decodePoll : D.Decoder Poll
decodePoll =
    D.map4 Poll
        (D.map PollId <| D.field "id" D.int)
        (D.map stringToMaybe <| D.field "title" D.string)
        (D.maybe <| D.field "description" D.string)
        (D.field "def" decodePollInfo)


encodePoll : Poll -> E.Value
encodePoll poll =
    E.object
        [ ( "id", E.int <| pollIdInt poll.pollId )
        , ( "title", E.string <| Maybe.withDefault "" poll.title )
        , ( "description", E.string <| Maybe.withDefault "" poll.description )
        , ( "def", encodePollInfo poll.pollInfo )
        ]


decodeVoter : D.Decoder Voter
decodeVoter =
    D.map2 Voter
        (D.map VoterId <| D.field "voterId" D.int)
        (D.field "name" D.string)


encodeVoter : Voter -> E.Value
encodeVoter voter =
    E.object
        [ ( "voterId", E.int <| voterIdInt voter.voterId )
        , ( "name", E.string voter.name )
        ]


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


encodeProject : Project -> E.Value
encodeProject project =
    E.object
        [ ( "title", E.string <| Maybe.withDefault "" project.title )
        , ( "polls", E.list encodePoll project.polls )
        , ( "lastPollId", E.int project.lastPollId )
        , ( "voters", E.list encodeVoter project.voters )
        , ( "lastVoterId", E.int project.lastVoterIdId )
        ]


encodeProjectAndKeys : Project -> Keys -> E.Value
encodeProjectAndKeys project keys =
    E.object
        [ ( "project", encodeProject project )
        , ( "projectKey", E.string keys.projectKey )
        , ( "secretKey", E.string keys.secretKey )
        ]
