module Candidate.TextCandidate.TextCandidateEncoding exposing (..)

import Candidate.TextCandidate.TextCandidateData exposing (TextCandidateItem)
import Data.CandidateId exposing (CandidateId(..))
import Json.Decode as D


decodeTextCandidateItem : D.Decoder TextCandidateItem
decodeTextCandidateItem =
    D.map3 TextCandidateItem
        (D.map CandidateId <| D.field "id" D.int)
        (D.field "value" D.string)
        (D.map (Maybe.withDefault False) <| (D.maybe <| D.field "hidden" D.bool))
