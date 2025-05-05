module Data.DataDecoders exposing (decodeProject)

import Candidate.DateCandidate.DateCandidateEncoding exposing (decodeDateCandidateItem)
import Candidate.TextCandidate.TextCandidateEncoding exposing (decodeTextCandidateItem)
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
import Poll.YesNoPoll.YesNoPollEncoding exposing (decodeYesNoVotesInfo)


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
