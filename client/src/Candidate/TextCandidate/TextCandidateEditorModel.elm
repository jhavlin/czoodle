module Candidate.TextCandidate.TextCandidateEditorModel exposing
    ( TextCandidateEditorModel
    , TextCandidateEditorMsg(..)
    , isChanged
    )

import Candidate.TextCandidate.TextCandidateData exposing (TextCandidateItem)
import Data.CandidateId exposing (CandidateId)
import Dict exposing (Dict)
import Set exposing (Set)


type TextCandidateEditorMsg
    = SetNewGenericPollItem Int String
    | AddGenericPollItem
    | RemoveGenericPollItem Int
    | RenameGenericPollItem CandidateId String
    | HideGenericPollItem CandidateId
    | UnhideGenericPollItem CandidateId
    | NoOp


type alias TextCandidateEditorModel =
    { originalItems : List TextCandidateItem
    , addedItems : List String
    , hiddenItems : Set Int
    , unhiddenItems : Set Int
    , renamedItems : Dict Int String
    }


isChanged : TextCandidateEditorModel -> Bool
isChanged { addedItems, hiddenItems, unhiddenItems, renamedItems } =
    (not <| List.isEmpty addedItems)
        || (not <| Set.isEmpty hiddenItems)
        || (not <| Set.isEmpty unhiddenItems)
        || (not <| Dict.isEmpty renamedItems)
