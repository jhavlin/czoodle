module Data.CandidateId exposing (CandidateId(..), candidateIdInt)


type CandidateId
    = CandidateId Int


candidateIdInt : CandidateId -> Int
candidateIdInt (CandidateId id) =
    id
