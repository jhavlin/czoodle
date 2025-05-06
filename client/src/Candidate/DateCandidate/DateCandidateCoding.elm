module Candidate.DateCandidate.DateCandidateCoding exposing (decodeDateCandidateItem, encodeDateCandidateItem)

import Candidate.DateCandidate.DateCandidateData exposing (DateCandidateItem)
import Candidate.DateCandidate.SDate exposing (dayToTuple)
import Common.CommonDecoders exposing (decodeDay)
import Common.CommonEncoders exposing (encodeDayTuple)
import Data.CandidateId exposing (CandidateId(..), candidateIdInt)
import Json.Decode as D
import Json.Encode as E


decodeDateCandidateItem : D.Decoder DateCandidateItem
decodeDateCandidateItem =
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
    in
    D.map3 DateCandidateItem
        (D.map CandidateId <| D.field "id" D.int)
        (D.field "value" strictDayDecoder)
        (D.map (Maybe.withDefault False) <| (D.maybe <| D.field "hidden" D.bool))


encodeDateCandidateItem : DateCandidateItem -> E.Value
encodeDateCandidateItem item =
    E.object
        ([ ( "id", E.int <| candidateIdInt item.candidateId )
         , ( "value", encodeDayTuple <| dayToTuple item.value )
         ]
            ++ (if item.hidden then
                    [ ( "hidden", E.bool True ) ]

                else
                    []
               )
        )
