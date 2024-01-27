module PollEditor.PollEditorUpdate exposing (update)

import Common.CommonModel exposing (CalendarStateModel, DayTuple)
import Common.ListUtils as ListUtils
import Data.DataModel exposing (OptionId, optionIdInt)
import Dict
import List
import PollEditor.PollEditorModel
    exposing
        ( DatePollEditorData
        , GenericPollEditorData
        , PollEditor(..)
        , PollEditorModel
        , PollEditorMsg(..)
        )
import SDate.SDate exposing (dayFromTuple, monthFromTuple, monthToTuple)
import Set



---- Update ----


update : PollEditorMsg -> PollEditorModel -> PollEditorModel
update msg model =
    case msg of
        SetPollTitle title ->
            setPollTitle title model

        SetPollDescription description ->
            setPollDescription description model

        SetNewGenericPollItem itemNumber itemVal ->
            doWithGenericPoll (setNewGenericItem itemNumber itemVal) model

        AddGenericPollItem ->
            doWithGenericPoll addGenericItem model

        RemoveGenericPollItem itemNumber ->
            doWithGenericPoll (removeGenericItem itemNumber) model

        RenameGenericPollItem optionId value ->
            doWithGenericPoll (renameGenericItem optionId value) model

        HideGenericPollItem optionId ->
            doWithGenericPoll (hideGenericItem optionId) model

        UnhideGenericPollItem optionId ->
            doWithGenericPoll (unhideGenericItem optionId) model

        AddDatePollItem dayTuple ->
            doWithDatePoll (selectDate dayTuple) model

        RemoveDatePollItem dayTuple ->
            doWithDatePoll (deselectDate dayTuple) model

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


doWithGenericPoll : (GenericPollEditorData -> GenericPollEditorData) -> PollEditorModel -> PollEditorModel
doWithGenericPoll fn model =
    case model.editor of
        GenericPollEditor genericPollData ->
            { model | editor = GenericPollEditor (fn genericPollData) }

        _ ->
            model


doWithDatePoll : (DatePollEditorData -> DatePollEditorData) -> PollEditorModel -> PollEditorModel
doWithDatePoll fn model =
    case model.editor of
        DatePollEditor state datePollData ->
            { model | editor = DatePollEditor state (fn datePollData) }

        _ ->
            model


doWithDatePollState : (CalendarStateModel -> CalendarStateModel) -> PollEditorModel -> PollEditorModel
doWithDatePollState fn model =
    case model.editor of
        DatePollEditor state datePollData ->
            { model | editor = DatePollEditor (fn state) datePollData }

        _ ->
            model


setPollTitle : String -> PollEditorModel -> PollEditorModel
setPollTitle newTitle model =
    let
        newChangedTitle =
            if newTitle == model.originalTitle then
                Nothing

            else
                Just newTitle
    in
    { model | changedTitle = newChangedTitle }


setPollDescription : String -> PollEditorModel -> PollEditorModel
setPollDescription newDescription model =
    let
        newChangedDescription =
            if newDescription == model.originalDescription then
                Nothing

            else
                Just newDescription
    in
    { model | changedDescription = newChangedDescription }


addGenericItem : GenericPollEditorData -> GenericPollEditorData
addGenericItem data =
    { data | addedItems = data.addedItems ++ [ "" ] }


setNewGenericItem : Int -> String -> GenericPollEditorData -> GenericPollEditorData
setNewGenericItem itemNumber newValue data =
    { data | addedItems = ListUtils.changeIndex (\_ -> newValue) itemNumber data.addedItems }


removeGenericItem : Int -> GenericPollEditorData -> GenericPollEditorData
removeGenericItem itemNumber data =
    let
        newItems =
            if List.length data.addedItems > 1 || not (List.isEmpty data.originalItems) then
                ListUtils.removeIndex itemNumber data.addedItems

            else
                ListUtils.changeIndex (\_ -> "") itemNumber data.addedItems
    in
    { data | addedItems = newItems }


renameGenericItem : OptionId -> String -> GenericPollEditorData -> GenericPollEditorData
renameGenericItem optionId value pollData =
    let
        valueOpt =
            ListUtils.findFirst (\i -> i.optionId == optionId) pollData.originalItems
                |> Maybe.map .value

        newRenamedItems =
            if Just value == valueOpt then
                Dict.remove (optionIdInt optionId) pollData.renamedItems

            else
                Dict.insert (optionIdInt optionId) value pollData.renamedItems
    in
    { pollData | renamedItems = newRenamedItems }


hideGenericItem : OptionId -> GenericPollEditorData -> GenericPollEditorData
hideGenericItem optionId pollData =
    let
        originallyHidden =
            ListUtils.findFirst (\i -> i.optionId == optionId) pollData.originalItems
                |> Maybe.map .hidden
                |> Maybe.withDefault False
    in
    if originallyHidden then
        { pollData | unhiddenItems = Set.remove (optionIdInt optionId) pollData.unhiddenItems }

    else
        { pollData | hiddenItems = Set.insert (optionIdInt optionId) pollData.hiddenItems }


unhideGenericItem : OptionId -> GenericPollEditorData -> GenericPollEditorData
unhideGenericItem optionId pollData =
    let
        originallyHidden =
            ListUtils.findFirst (\i -> i.optionId == optionId) pollData.originalItems
                |> Maybe.map .hidden
                |> Maybe.withDefault False
    in
    if originallyHidden then
        { pollData | unhiddenItems = Set.insert (optionIdInt optionId) pollData.unhiddenItems }

    else
        { pollData | hiddenItems = Set.remove (optionIdInt optionId) pollData.hiddenItems }


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


selectDate : DayTuple -> DatePollEditorData -> DatePollEditorData
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
                        { data | unhiddenItems = Set.insert (optionIdInt optionItem.optionId) data.unhiddenItems }

                    else
                        { data | hiddenItems = Set.remove (optionIdInt optionItem.optionId) data.hiddenItems }

                Nothing ->
                    { data | addedItems = Set.insert dayTuple data.addedItems }
    in
    case sDayOpt of
        Just _ ->
            res

        Nothing ->
            data



-- Some problem with day tuple, return original data


deselectDate : DayTuple -> DatePollEditorData -> DatePollEditorData
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
                        { data | unhiddenItems = Set.remove (optionIdInt optionItem.optionId) data.unhiddenItems }

                    else
                        { data | hiddenItems = Set.insert (optionIdInt optionItem.optionId) data.hiddenItems }

                Nothing ->
                    { data | addedItems = Set.remove dayTuple data.addedItems }
    in
    case sDayOpt of
        Just _ ->
            res

        Nothing ->
            data



-- Some problem with day tuple, return original data
