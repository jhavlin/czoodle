module Data.DataModel exposing
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

import Candidate.DateCandidate.DateCandidateData exposing (DateCandidateItem)
import Candidate.TextCandidate.TextCandidateData exposing (TextCandidateItem)
import Data.PollRows exposing (PollRows)
import Data.VoterId exposing (VoterId)
import Poll.YesNoPoll.YesNoPollData exposing (YesNoOption, YesNoPollSettings)



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


type VotesInfo
    = YesNotVotesInfo
        { settings : YesNoPollSettings
        , votes : PollRows YesNoOption
        }


type alias PollInfo =
    { candidateInfo : CandidatesInfo
    , votesInfo : VotesInfo
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
    , lastVoterIdId : Int
    }



-----------------------------------------------------------
---- Functions
-----------------------------------------------------------


pollIdInt : PollId -> Int
pollIdInt (PollId id) =
    id
