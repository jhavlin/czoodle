module Vote.VoteModel exposing
    ( ChangesInProject(..)
    , Model
    , ProjectState(..)
    , ViewMode(..)
    , ViewState
    , ViewStates
    , emptyViewState
    )

import Candidate.DateCandidate.SDate exposing (SDay)
import Data.CandidateId exposing (CandidateId(..), candidateIdInt)
import Data.Comments exposing (RowComment(..))
import Data.DataModel
    exposing
        ( CandidatesInfo(..)
        , Keys
        , Poll
        , PollId(..)
        , Project
        , pollIdInt
        )
import Data.PollRows exposing (VoterRow, VoterRowStatus(..))
import Data.VoterId exposing (VoterId(..), voterIdInt)
import Dict exposing (Dict)
import EditProject.EditProjectModel exposing (ChangesInProjectDefinition)
import Poll.PollKinds as PollKinds exposing (KindOfChangedVoterRow, KindOfPollInnerMsg, KindOfVoterRow, KindOfVotesInfo)
import Set exposing (Set)
import Translations.Translation exposing (Translation)


type ViewMode
    = OptionsInRow


type alias ViewState =
    { viewMode : ViewMode
    }


type alias ViewStates =
    Dict Int ViewState


type ProjectState
    = Loading
    | Loaded Project ChangesInProject ViewStates
    | Error String
    | Saving Project ChangesInProject ViewStates


type alias Model =
    { keys : Keys
    , projectState : ProjectState
    , today : SDay
    , translation : Translation
    }


type ChangesInProject
    = AddedVoter { voterName : String, rowsInPolls : Dict Int KindOfVoterRow }
    | UpdatedVoter { id : VoterId, changedName : Maybe String, changesInPolls : Dict Int KindOfChangedVoterRow }
    | DeletedVoter VoterId
    | ChangedDefinition ChangesInProjectDefinition


emptyViewState : ViewState
emptyViewState =
    { viewMode = OptionsInRow
    }
