{- Helper types for votes in a poll -}


module Data.PollRows exposing (..)

import Data.Comments exposing (RowComment, VoteComment)
import Dict exposing (Dict)



{- Type for a pair of  single vote (yes/no, number of stars and a user comment, possibly empty string -}


type alias VoteWithComment voteType =
    { vote : voteType
    , comment : VoteComment
    }


type alias ChangedVoteWithComment voteType =
    { vote : voteType
    , changedComment : Maybe VoteComment
    }



{- Type for one row in a poll, mapping from candidate id to selected option and a vote comment -}


type alias VoterVotes voteType =
    Dict Int (VoteWithComment voteType)


type alias ChangedVoterVotes voteType =
    Dict Int (ChangedVoteWithComment voteType)



{- Type for one row in a poll with a row comment -}


type alias VoterRow voteType =
    { voterVotes : VoterVotes voteType, rowComment : RowComment, status : VoterRowStatus }


type alias ChangedVoterRow voteType =
    { changedVoterComment : Maybe RowComment, rowChange : RowChange voteType }


type RowChange voteType
    = VotesChanged (ChangedVoterVotes voteType)
    | RowSkipped
    | RowUnSkipped


type VoterRowStatus
    = Valid
    | Skipped



{- Type for all rows in a poll, mapping from voter id to object with voter row and a comment -}


type alias PollRows voteType =
    Dict Int (VoterRow voteType)
