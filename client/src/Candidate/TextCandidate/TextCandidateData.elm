module Candidate.TextCandidate.TextCandidateData exposing (..)

import Data.CandidateId exposing (CandidateId)


type alias TextCandidateItem =
    { candidateId : CandidateId
    , value : String
    , hidden : Bool
    }
