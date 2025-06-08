module Poll.PollCommon exposing (PollOptionInfo, SelectedVotes(..))

import Data.CandidateId exposing (CandidateId)
import Data.PollRows exposing (VoterRow)



{- Info needed when rendering one cell in poll table. -}


type alias PollOptionInfo a =
    { candidateId : CandidateId
    , candidatesCount : Int
    , selectedVotes : SelectedVotes a
    }


type SelectedVotes a
    = NewVoterVotes (VoterRow a)
    | ExistingVotesAndChanges (VoterRow a) (VoterRow a)
    | ExistingVotes (VoterRow a)
