module Candidate.DateCandidate.DateCandidatesEditorUpdate exposing (update)

import Candidate.DateCandidate.DateCandidatesEditorModel
    exposing
        ( DateCandidatesEditorData
        , DateCandidatesEditorModel
        , DateCandidatesEditorMsg(..)
        )
import Candidate.DateCandidate.SDate exposing (dayFromTuple, monthFromTuple, monthToTuple)
import Common.CommonModel exposing (CalendarStateModel, DayTuple)
import Common.ListUtils as ListUtils
import Data.CandidateId exposing (candidateIdInt)
import Set



---- Update ----


update : DateCandidatesEditorMsg -> DateCandidatesEditorModel -> DateCandidatesEditorModel
update msg model =
    case msg of
        AddDatePollItem dayTuple ->
            doWithDatePollData (\data -> selectDate dayTuple data) model

        RemoveDatePollItem dayTuple ->
            doWithDatePollData (\data -> deselectDate dayTuple data) model

        SetCalendarMonth sMonth ->
            doWithDatePollState (\state -> { state | month = sMonth }) model

        SetCalendarMonthDirect str ->
            doWithDatePollState (setCalendarMonthDirect str) model

        SetCalendarYearDirect str ->
            doWithDatePollState (setCalendarYearDirect str) model

        SetHighlightedDay maybeTuple ->
            doWithDatePollState (\state -> { state | highlightedDay = maybeTuple }) model

        NoOp ->
            model


doWithDatePollData : (DateCandidatesEditorData -> DateCandidatesEditorData) -> DateCandidatesEditorModel -> DateCandidatesEditorModel
doWithDatePollData fn model =
    { model | data = fn model.data }


doWithDatePollState : (CalendarStateModel -> CalendarStateModel) -> DateCandidatesEditorModel -> DateCandidatesEditorModel
doWithDatePollState fn model =
    { model | state = fn model.state }


setCalendarMonthDirect : String -> CalendarStateModel -> CalendarStateModel
setCalendarMonthDirect str data =
    let
        ( year, _ ) =
            monthToTuple data.month

        monthOpt =
            String.toInt str

        newMonthOpt =
            Maybe.andThen (\m -> monthFromTuple ( year, m )) monthOpt
    in
    case newMonthOpt of
        Just sMonth ->
            { data | month = sMonth }

        Nothing ->
            data


setCalendarYearDirect : String -> CalendarStateModel -> CalendarStateModel
setCalendarYearDirect str data =
    let
        ( _, month ) =
            monthToTuple data.month

        yearOpt =
            String.toInt str

        newYearOpt =
            Maybe.andThen (\y -> monthFromTuple ( y, month )) yearOpt
    in
    case newYearOpt of
        Just sMonth ->
            { data | month = sMonth }

        Nothing ->
            data


selectDate : DayTuple -> DateCandidatesEditorData -> DateCandidatesEditorData
selectDate dayTuple data =
    let
        sDayOpt =
            dayFromTuple dayTuple

        originalDateOptionItem =
            Maybe.andThen (\sDay -> ListUtils.findFirst (\i -> i.value == sDay) data.originalItems) sDayOpt

        res =
            case originalDateOptionItem of
                Just optionItem ->
                    if optionItem.hidden then
                        { data | unhiddenItems = Set.insert (candidateIdInt optionItem.candidateId) data.unhiddenItems }

                    else
                        { data | hiddenItems = Set.remove (candidateIdInt optionItem.candidateId) data.hiddenItems }

                Nothing ->
                    { data | addedItems = Set.insert dayTuple data.addedItems }
    in
    case sDayOpt of
        Just _ ->
            res

        Nothing ->
            data



-- Some problem with day tuple, return original data


deselectDate : DayTuple -> DateCandidatesEditorData -> DateCandidatesEditorData
deselectDate dayTuple data =
    let
        sDayOpt =
            dayFromTuple dayTuple

        originalDateOptionItem =
            Maybe.andThen (\sDay -> ListUtils.findFirst (\i -> i.value == sDay) data.originalItems) sDayOpt

        res =
            case originalDateOptionItem of
                Just optionItem ->
                    if optionItem.hidden then
                        { data | unhiddenItems = Set.remove (candidateIdInt optionItem.candidateId) data.unhiddenItems }

                    else
                        { data | hiddenItems = Set.insert (candidateIdInt optionItem.candidateId) data.hiddenItems }

                Nothing ->
                    { data | addedItems = Set.remove dayTuple data.addedItems }
    in
    case sDayOpt of
        Just _ ->
            res

        Nothing ->
            data
