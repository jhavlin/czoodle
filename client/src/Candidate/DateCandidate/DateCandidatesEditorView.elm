module Candidate.DateCandidate.DateCandidatesEditorView exposing (viewDateCandidatesEditor, ViewConfig)

import Candidate.DateCandidate.DateCandidatesEditorModel
    exposing
        ( DateCandidatesEditorData
        , DateCandidatesEditorModel
        , DateCandidatesEditorMsg(..)
        )
import Candidate.DateCandidate.SDate
    exposing
        ( SDay
        , dayFromTuple
        , dayToTuple
        , monthFromDay
        , monthFromTuple
        , monthToTuple
        , nextMonth
        , prevMonth
        , weeksInMonth
        )
import Common.CommonModel exposing (CalendarStateModel)
import Common.CommonView as CommonView exposing (optClass)
import Common.ListUtils as ListUtils
import Data.CandidateId exposing (candidateIdInt)
import Html exposing (Html, a, button, div, input, option, select, text)
import Html.Attributes exposing (class, selected, tabindex, title, type_, value)
import Html.Events exposing (onClick, onInput, onMouseEnter, onMouseLeave)
import Set
import Translations.Translation exposing (Translation)


type alias ViewConfig outerMsg =
    { outerMessage : DateCandidatesEditorMsg -> outerMsg
    , today : SDay
    , translation : Translation
    }


viewDateCandidatesEditor : DateCandidatesEditorModel -> ViewConfig a -> Html a
viewDateCandidatesEditor model viewConfig =
    div []
        [ div [ class "poll-instructions" ]
            [ text viewConfig.translation.pollEditor.optionsInstructionsDate ]
        , viewDateCalendar model.state model.data viewConfig
        , viewPollDateItemTags model.state model.data viewConfig
        ]


viewDateCalendar : CalendarStateModel -> DateCandidatesEditorData -> ViewConfig a -> Html a
viewDateCalendar state pollData viewConfig =
    let
        weeks =
            weeksInMonth state.month

        cellFn =
            viewDateCalendarCell state pollData viewConfig

        weekRow days =
            div [ class "calendar-row" ] (List.map cellFn days)

        controlsRow =
            viewDateCalendarControls state viewConfig

        headerRow =
            viewDateCalendarHeaderRow viewConfig.translation

        rows =
            List.map weekRow weeks
    in
    div [ class "calendar-table" ] (controlsRow :: headerRow :: rows)


viewDateCalendarControls : CalendarStateModel -> ViewConfig a -> Html a
viewDateCalendarControls state viewConfig =
    let
        ( year, month ) =
            monthToTuple state.month

        names =
            viewConfig.translation.common.monthNames

        nameToOption index name =
            option
                [ selected (index + 1 == month), value (String.fromInt <| index + 1) ]
                [ text name ]

        options =
            List.indexedMap nameToOption names
    in
    div
        [ class "calendar-controls" ]
        [ div [ class "calendar-controls-direct" ]
            [ select
                [ class "common-input common-select common-group-first calendar-controls-month"
                , onInput (viewConfig.outerMessage << SetCalendarMonthDirect)
                ]
                options
            , input
                [ class "common-input common-group-last calendar-controls-year"
                , type_ "number"
                , value (String.fromInt year)
                , Html.Attributes.min "1970"
                , CommonView.onChange (viewConfig.outerMessage << SetCalendarYearDirect)
                ]
                []
            ]
        , div [ class "calendar-controls-buttons" ]
            [ button
                [ class "common-button common-input calendar-controls-buttons-today"
                , onClick (viewConfig.outerMessage <| SetCalendarMonth (monthFromDay viewConfig.today))
                ]
                [ text viewConfig.translation.common.today ]
            , text " "
            , button
                [ class "common-button common-wide common-input common-group-first"
                , onClick (viewConfig.outerMessage <| SetCalendarMonth (prevMonth state.month))
                ]
                [ text " < " ]
            , button
                [ class "common-button common-wide common-input common-group-last"
                , onClick (viewConfig.outerMessage <| SetCalendarMonth (nextMonth state.month))
                ]
                [ text " > " ]
            ]
        ]


viewDateCalendarHeaderRow : Translation -> Html a
viewDateCalendarHeaderRow translation =
    let
        days =
            translation.common.dayNamesShort

        dayToCell day =
            div [ class "calendar-cell calendar-header-cell" ] [ text day ]

        cells =
            List.map dayToCell days
    in
    div [ class "calendar-row calendar-header-row" ] cells


viewDateCalendarCell : CalendarStateModel -> DateCandidatesEditorData -> ViewConfig a -> SDay -> Html a
viewDateCalendarCell state pollData viewConfig sDay =
    let
        dayTuple =
            dayToTuple sDay

        ( _, month, date ) =
            dayTuple

        ( _, activeMonth ) =
            monthToTuple state.month

        active =
            month == activeMonth

        future =
            dayTuple >= dayToTuple viewConfig.today

        originalDateOptionItem =
            ListUtils.findFirst (\i -> i.value == sDay) pollData.originalItems

        originalSelected =
            case originalDateOptionItem of
                Just dateOptionItem ->
                    not dateOptionItem.hidden
                        && (not <| Set.member (candidateIdInt dateOptionItem.candidateId) pollData.hiddenItems)

                Nothing ->
                    False

        selected =
            originalSelected || Set.member dayTuple pollData.addedItems

        onClickAction =
            if selected then
                viewConfig.outerMessage <| RemoveDatePollItem dayTuple

            else
                viewConfig.outerMessage <| AddDatePollItem dayTuple

        cellClass =
            "calendar-cell"
                ++ optClass selected "calendar-cell-selected"
                ++ optClass active "calendar-cell-active"
                ++ optClass future "calendar-cell-future"
                ++ optClass (state.highlightedDay == Just dayTuple) "calendar-cell-highlighted"
                ++ optClass (state.today == sDay) "calendar-cell-today"
    in
    a
        [ class cellClass
        , onClick onClickAction
        , onMouseEnter <| viewConfig.outerMessage <| SetHighlightedDay (Just dayTuple)
        , onMouseLeave <| viewConfig.outerMessage <| SetHighlightedDay Nothing
        , tabindex 0
        ]
        [ String.fromInt date |> text
        ]


viewPollDateItemTags : CalendarStateModel -> DateCandidatesEditorData -> ViewConfig a -> Html a
viewPollDateItemTags state pollData viewConfig =
    let
        ( shownYear, shownMonth ) =
            monthToTuple state.month

        tupleAsText ( _, month, date ) =
            String.fromInt date
                ++ ". "
                ++ String.fromInt month
                ++ "."

        tupleAsFullText ( year, month, date ) hidden =
            String.fromInt date
                ++ ". "
                ++ String.fromInt month
                ++ ". "
                ++ String.fromInt year
                ++ (if hidden then
                        viewConfig.translation.pollEditor.hiddenSuffix

                    else
                        ""
                   )

        tupleToTag (( year, month, _ ) as tuple) =
            let
                originalItem =
                    ListUtils.findFirst (\i -> Just i.value == dayFromTuple tuple) pollData.originalItems

                isHidden item =
                    (not item.hidden && Set.member (candidateIdInt item.candidateId) pollData.hiddenItems)
                        || (item.hidden && (not <| Set.member (candidateIdInt item.candidateId) pollData.unhiddenItems))

                hidden =
                    Maybe.map isHidden originalItem |> Maybe.withDefault False
            in
            div
                [ class "poll-date-tag"
                , onMouseEnter <| viewConfig.outerMessage (SetHighlightedDay (Just tuple))
                , onMouseLeave <| viewConfig.outerMessage (SetHighlightedDay Nothing)
                ]
                [ div
                    [ class
                        ("poll-date-tag-name"
                            ++ optClass (( shownYear, shownMonth ) /= ( year, month )) "poll-date-tag-name-active"
                            ++ optClass (state.highlightedDay == Just tuple) "poll-date-tag-name-highlighted"
                            ++ optClass hidden "poll-date-tag-name-hidden"
                        )
                    , onClick
                        (viewConfig.outerMessage <|
                            Maybe.withDefault NoOp (Maybe.map (\m -> SetCalendarMonth m) (monthFromTuple ( year, month )))
                        )
                    , title <| tupleAsFullText tuple hidden
                    ]
                    [ text <| tupleAsText tuple ]
                , div
                    [ class
                        ("poll-date-tag-delete"
                            ++ optClass hidden "poll-date-tag-delete-hidden"
                        )
                    , onClick <|
                        if hidden then
                            viewConfig.outerMessage (AddDatePollItem tuple)

                        else
                            viewConfig.outerMessage (RemoveDatePollItem tuple)
                    ]
                    [ if hidden then
                        text "👁"

                      else
                        text "✗"
                    ]
                ]

        allDays =
            Set.toList <|
                Set.union pollData.addedItems <|
                    Set.fromList <|
                        List.map (\i -> dayToTuple i.value) pollData.originalItems

        tags =
            List.map tupleToTag allDays

        info =
            if List.isEmpty allDays then
                [ div [ class "poll-date-tag-info" ]
                    [ text viewConfig.translation.pollEditor.nothingSelected ]
                ]

            else
                []
    in
    div [ class "poll-date-tags" ]
        ((div [] [ text viewConfig.translation.pollEditor.optionsOverview ] :: tags) ++ info)
