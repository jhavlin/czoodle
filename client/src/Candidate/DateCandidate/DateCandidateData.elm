module Candidate.DateCandidate.DateCandidateData exposing (DateCandidateItem)

import Candidate.DateCandidate.SDate exposing (SDay)
import Data.CandidateId exposing (CandidateId)


type alias DateCandidateItem =
    { candidateId : CandidateId
    , value : SDay
    , hidden : Bool
    }
