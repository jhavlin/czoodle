module PollEditor.PollEditorModel exposing
    ( DatePollEditorData
    , GenericPollEditorData
    , PollEditor(..)
    , PollEditorModel
    , PollEditorMsg(..)
    , isChanged
    )

import Common.CommonModel exposing (CalendarStateModel, DayTuple)
import Data.DataModel exposing (DateOptionItem, GenericOptionItem, OptionId)
import Dict exposing (Dict)
import Maybe exposing (Maybe)
import SDate.SDate exposing (SMonth)
import Set exposing (Set)


type PollEditorMsg
    = SetPollTitle String
    | SetPollDescription String
    | SetNewGenericPollItem Int String
    | AddGenericPollItem
    | RemoveGenericPollItem Int
    | RenameGenericPollItem OptionId String
    | HideGenericPollItem OptionId
    | UnhideGenericPollItem OptionId
    | AddDatePollItem DayTuple
    | RemoveDatePollItem DayTuple
    | SetCalendarMonth SMonth
    | SetCalendarMonthDirect String
    | SetCalendarYearDirect String
    | SetHighlightedDay (Maybe DayTuple)
    | NoOp


type alias PollEditorModel =
    { originalTitle : String
    , originalDescription : String
    , changedTitle : Maybe String
    , changedDescription : Maybe String
    , editor : PollEditor
    }


type PollEditor
    = DatePollEditor CalendarStateModel DatePollEditorData
    | GenericPollEditor GenericPollEditorData


type alias DatePollEditorData =
    { originalItems : List DateOptionItem
    , addedItems : Set DayTuple
    , hiddenItems : Set Int
    , unhiddenItems : Set Int
    }


type alias GenericPollEditorData =
    { originalItems : List GenericOptionItem
    , addedItems : List String
    , hiddenItems : Set Int
    , unhiddenItems : Set Int
    , renamedItems : Dict Int String
    }


isJust : Maybe a -> Bool
isJust maybe =
    case maybe of
        Just _ ->
            True

        Nothing ->
            False


isChanged : PollEditorModel -> Bool
isChanged editorModel =
    isJust editorModel.changedTitle
        || isJust editorModel.changedDescription
        || (case editorModel.editor of
                DatePollEditor _ { addedItems, hiddenItems, unhiddenItems } ->
                    (not <| Set.isEmpty addedItems)
                        || (not <| Set.isEmpty hiddenItems)
                        || (not <| Set.isEmpty unhiddenItems)

                GenericPollEditor { addedItems, hiddenItems, unhiddenItems, renamedItems } ->
                    (not <| List.isEmpty addedItems)
                        || (not <| Set.isEmpty hiddenItems)
                        || (not <| Set.isEmpty unhiddenItems)
                        || (not <| Dict.isEmpty renamedItems)
           )
