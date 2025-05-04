module Candidate.DateCandidate.DateCandidateEncoding exposing (decodeDateCandidateItem)

import Candidate.DateCandidate.DateCandidateData exposing (DateCandidateItem)
import Common.CommonDecoders exposing (decodeDay)
import Data.CandidateId exposing (CandidateId(..))
import Json.Decode as D


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
