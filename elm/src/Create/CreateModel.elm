module Create.CreateModel exposing (CalendarStateModel, CreatedProjectInfo, Model, Msg(..), NewDatePollData, NewGenericPollData, NewPoll, NewPollModel(..), newPollsToProject)

import Common.CommonUtils exposing (stringToMaybe)
import Common.ListUtils exposing (filterNothings)
import Data.DataModel exposing (DayTuple, OptionId(..), Poll, PollId(..), PollInfo(..), Project)
import SDate.SDate exposing (SDay, SMonth, dayFromTuple)
import Set exposing (..)



{-
   -
   -Types
   -
-}


type Msg
    = SetTitle String
    | AddGenericPoll
    | AddDatePoll
    | RemovePoll Int
    | SetPollTitle Int String
    | SetPollDescription Int String
    | SetGenericPollItem Int Int String
    | AddGenericPollItem Int
    | RemoveGenericPollItem Int Int
    | AddDatePollItem Int DayTuple
    | RemoveDatePollItem Int DayTuple
    | SetCalendarMonth Int SMonth
    | SetCalendarMonthDirect Int String
    | SetCalendarYearDirect Int String
    | SetHighlightedDay Int (Maybe DayTuple)
    | Persist
    | ProjectCreated CreatedProjectInfo
    | NoOp


type alias NewPoll =
    { title : String
    , description : String
    , def : NewPollModel
    }


type alias CalendarStateModel =
    { month : SMonth
    , highlightedDay : Maybe DayTuple
    , today : SDay
    }


type NewPollModel
    = NewDatePollModel CalendarStateModel NewDatePollData
    | NewGenericPollModel NewGenericPollData


type alias NewGenericPollData =
    { items : List String }


type alias NewDatePollData =
    { items : Set DayTuple }


type alias CreatedProjectInfo =
    { projectKey : String
    , secretKey : String
    }


type alias Model =
    { title : String
    , polls : List NewPoll
    , today : SDay
    , wait : Bool
    , created : Maybe CreatedProjectInfo
    , baseUrl : String
    }



{-
   -
   - Functions
   -
-}


newPollsToProject : Model -> Project
newPollsToProject { title, polls } =
    let
        newDatePollDataToPollInfo { items } =
            Set.toList items
                |> List.map dayFromTuple
                |> filterNothings
                |> List.indexedMap (\index item -> { optionId = OptionId <| 1 + index, value = item })

        newGenericPollDataToPollInfo { items } =
            List.filter (\v -> not <| String.isEmpty <| String.trim v) items
                |> List.indexedMap (\index item -> { optionId = OptionId <| 1 + index, value = item })

        newPollModelToPollInfo : NewPollModel -> PollInfo
        newPollModelToPollInfo newPollModel =
            case newPollModel of
                NewDatePollModel _ newPollData ->
                    DatePollInfo { items = newDatePollDataToPollInfo newPollData }

                NewGenericPollModel newPollData ->
                    GenericPollInfo { items = newGenericPollDataToPollInfo newPollData }

        newPollToPoll : Int -> NewPoll -> Poll
        newPollToPoll index newPoll =
            { pollId = PollId <| index + 1
            , title = stringToMaybe newPoll.title
            , description = stringToMaybe newPoll.description
            , pollInfo = newPollModelToPollInfo newPoll.def
            , personRows = []
            , lastPersonId = 0
            }

        finalPolls =
            List.indexedMap newPollToPoll polls
    in
    { title = stringToMaybe title
    , polls = finalPolls
    , lastPollId = 1 + List.length finalPolls
    , comments = []
    , lastCommentId = 0
    }
