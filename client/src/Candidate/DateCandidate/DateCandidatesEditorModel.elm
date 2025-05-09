module Candidate.DateCandidate.DateCandidatesEditorModel exposing
    ( DateCandidatesEditorModel
    , DateCandidatesEditorMsg(..)
    , DateCandidatesEditorData
    , isChanged
    )

import Candidate.DateCandidate.DateCandidateData exposing (DateCandidateItem)
import Candidate.DateCandidate.SDate exposing (SMonth)
import Common.CommonModel exposing (CalendarStateModel, DayTuple)
import Maybe exposing (Maybe)
import Set exposing (Set)


type DateCandidatesEditorMsg
    = AddDatePollItem DayTuple
    | RemoveDatePollItem DayTuple
    | SetCalendarMonth SMonth
    | SetCalendarMonthDirect String
    | SetCalendarYearDirect String
    | SetHighlightedDay (Maybe DayTuple)
    | NoOp


type alias DateCandidatesEditorData =
    { originalItems : List DateCandidateItem
    , addedItems : Set DayTuple
    , hiddenItems : Set Int
    , unhiddenItems : Set Int
    }


type alias DateCandidatesEditorModel =
    { data : DateCandidatesEditorData
    , state : CalendarStateModel
    }


isChanged : DateCandidatesEditorModel -> Bool
isChanged editorModel =
    (not <| Set.isEmpty editorModel.data.addedItems)
        || (not <| Set.isEmpty editorModel.data.hiddenItems)
        || (not <| Set.isEmpty editorModel.data.unhiddenItems)
