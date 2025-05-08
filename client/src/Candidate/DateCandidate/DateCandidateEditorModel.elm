module Candidate.DateCandidate.DateCandidateEditorModel exposing
    ( DateCandidateEditorModel
    , DateCandidateEditorMsg(..)
    , DateCandidateEditorData
    , isChanged
    )

import Candidate.DateCandidate.DateCandidateData exposing (DateCandidateItem)
import Candidate.DateCandidate.SDate exposing (SMonth)
import Common.CommonModel exposing (CalendarStateModel, DayTuple)
import Maybe exposing (Maybe)
import Set exposing (Set)


type DateCandidateEditorMsg
    = AddDatePollItem DayTuple
    | RemoveDatePollItem DayTuple
    | SetCalendarMonth SMonth
    | SetCalendarMonthDirect String
    | SetCalendarYearDirect String
    | SetHighlightedDay (Maybe DayTuple)
    | NoOp


type alias DateCandidateEditorData =
    { originalItems : List DateCandidateItem
    , addedItems : Set DayTuple
    , hiddenItems : Set Int
    , unhiddenItems : Set Int
    }


type alias DateCandidateEditorModel =
    { data : DateCandidateEditorData
    , state : CalendarStateModel
    }


isChanged : DateCandidateEditorModel -> Bool
isChanged editorModel =
    (not <| Set.isEmpty editorModel.data.addedItems)
        || (not <| Set.isEmpty editorModel.data.hiddenItems)
        || (not <| Set.isEmpty editorModel.data.unhiddenItems)
