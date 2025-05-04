module Data.DataModel exposing
    ( Keys
    , Poll
    , PollId(..)
    , PollInfo(..)
    , Project
    , RowComment(..)
    , Voter
    , VoterId(..)
    , pollIdInt
    , voterIdInt
    )

import Candidate.DateCandidate.DateCandidateData exposing (DateCandidateItem)
import Candidate.TextCandidate.TextCandidateData exposing (TextCandidateItem)
import Data.CandidateId exposing (CandidateId)
import Dict exposing (Dict)
import Poll.YesNoPoll.YesNoPollData exposing (YesNoPollSettings, YesNoVote)



-----------------------------------------------------------
---- Types
-----------------------------------------------------------


type alias Keys =
    { projectKey : String
    , secretKey : String
    }


type PollId
    = PollId Int


type VoterId
    = VoterId Int


type alias Voter =
    { voterId : VoterId
    , name : String
    }


type RowComment
    = RowComment String


type PollInfo
    = DatePollInfo
        { items : List DateCandidateItem
        , settings : YesNoPollSettings
        , votes : Dict VoterId ( Dict CandidateId YesNoVote, RowComment )
        }
    | GenericPollInfo
        { items : List TextCandidateItem
        , settings : YesNoPollSettings
        , votes : Dict VoterId ( Dict Int YesNoVote, RowComment )
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
    , lastPersonId : Int
    }



-----------------------------------------------------------
---- Functions
-----------------------------------------------------------


pollIdInt : PollId -> Int
pollIdInt (PollId id) =
    id


voterIdInt : VoterId -> Int
voterIdInt (VoterId id) =
    id
