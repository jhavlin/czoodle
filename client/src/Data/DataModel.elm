module Data.DataModel exposing
    ( CandidatesInfo(..)
    , Keys
    , Poll
    , PollId(..)
    , PollInfo
    , Project
    , Voter
    , pollIdInt
    )

import Candidate.DateCandidate.DateCandidateData exposing (DateCandidateItem)
import Candidate.TextCandidate.TextCandidateData exposing (TextCandidateItem)
import Data.VoterId exposing (VoterId)
import Poll.PollKinds exposing (KindOfVotesInfo)



-----------------------------------------------------------
---- Types
-----------------------------------------------------------


type alias Keys =
    { projectKey : String
    , secretKey : String
    }


type PollId
    = PollId Int


type alias Voter =
    { voterId : VoterId
    , name : String
    }


type CandidatesInfo
    = DateCandidatesInfo (List DateCandidateItem)
    | TextCandidatesInfo (List TextCandidateItem)





type alias PollInfo =
    { candidatesInfo : CandidatesInfo
    , votesInfo : KindOfVotesInfo
    }


type alias Poll =
    { pollId : PollId
    , title : Maybe String
    , description : Maybe String
    , pollInfo : PollInfo
    }


type alias Project =
    { title : Maybe String
    , polls : List Poll
    , lastPollId : Int
    , voters : List Voter
    , lastVoterId : Int
    }



-----------------------------------------------------------
---- Functions
-----------------------------------------------------------


pollIdInt : PollId -> Int
pollIdInt (PollId id) =
    id
