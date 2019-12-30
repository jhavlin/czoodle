module PollEditor.PollEditorView exposing
    ( ViewConfig
    , viewPoll
    )

import Common.CommonModel exposing (CalendarStateModel)
import Common.CommonView as CommonView exposing (optClass)
import Common.ListUtils as ListUtils
import Data.DataModel exposing (GenericOptionItem, optionIdInt)
import Dict
import Html exposing (Html, a, button, div, input, label, li, ol, option, select, span, text, textarea)
import Html.Attributes exposing (class, disabled, min, placeholder, selected, tabindex, title, type_, value)
import Html.Events exposing (onClick, onInput, onMouseEnter, onMouseLeave)
import PollEditor.PollEditorModel
    exposing
        ( DatePollEditorData
        , GenericPollEditorData
        , PollEditor(..)
        , PollEditorModel
        , PollEditorMsg(..)
        )
import SDate.SDate
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
import Set


type alias ViewConfig outerMsg =
    { outerMessage : PollEditorMsg -> outerMsg
    , removePollMessage : Maybe outerMsg
    , today : SDay
    , pollNumber : Int
    }


viewPoll : PollEditorModel -> ViewConfig a -> Html a
viewPoll model viewConfig =
    case model.editor of
        GenericPollEditor genericDef ->
            viewPollGeneric model genericDef viewConfig

        DatePollEditor state dateDef ->
            viewPollDate model state dateDef viewConfig


viewDeletePollButton : ViewConfig a -> Html a
viewDeletePollButton viewConfig =
    case viewConfig.removePollMessage of
        Just msg ->
            div [ class "poll-header-delete" ]
                [ button
                    [ class "delete-poll-button common-button common-input"
                    , onClick msg
                    , title "Odstranit hlasování"
                    ]
                    [ text "✗" ]
                ]

        Nothing ->
            div [] []


viewPollGeneric : PollEditorModel -> GenericPollEditorData -> ViewConfig a -> Html a
viewPollGeneric model pollData viewConfig =
    div [ class "poll poll-generic" ]
        [ div [ class "poll-header-row" ]
            [ div [ class "poll-header-name" ]
                [ text ("Hlasování " ++ String.fromInt (viewConfig.pollNumber + 1) ++ ": Obecné") ]
            , viewDeletePollButton viewConfig
            ]
        , div [ class "poll-body" ]
            [ div [ class "poll-name-row" ]
                [ label []
                    [ span [ class "poll-name-label" ] [ text "Nadpis:" ]
                    , input
                        [ type_ "text"
                        , class "common-input poll-name-input"
                        , placeholder "např. Co za dárek? nebo Jaká hospoda?"
                        , value <| Maybe.withDefault model.originalTitle model.changedTitle
                        , onInput (viewConfig.outerMessage << SetPollTitle)
                        ]
                        []
                    ]
                , label []
                    [ span [ class "poll-description-label" ] [ text "Popis:" ]
                    , textarea
                        [ class "common-input poll-description-textarea"
                        , placeholder "Sem můžete napsat podrobnější informace o hlasování, ale nemusíte."
                        , value <| Maybe.withDefault model.originalDescription model.changedDescription
                        , onInput (viewConfig.outerMessage << SetPollDescription)
                        ]
                        []
                    ]
                ]
            , div [ class "poll-instructions" ]
                [ text "Zadejte možnosti, o kterých se bude hlasovat." ]
            , div [ class "poll-options" ]
                [ div [ class "poll-options-header" ] [ text "Možnosti:" ]
                , ol [ class "poll-options-list" ] (viewPollGenericItems pollData viewConfig)
                ]
            ]
        ]


viewPollGenericItems : GenericPollEditorData -> ViewConfig a -> List (Html a)
viewPollGenericItems pollData viewConfig =
    let
        existing =
            List.map (\item -> viewPollGenericItemExisting item pollData viewConfig) pollData.originalItems

        new =
            List.indexedMap (\itemNumber item -> viewPollGenericItemNew itemNumber item pollData viewConfig) pollData.addedItems

        add =
            li [ class "poll-option-generic" ]
                [ button
                    [ onClick (viewConfig.outerMessage AddGenericPollItem)
                    , class "common-button common-button-bigger colors-neutral common-add-icon"
                    ]
                    [ text "Přidat možnost" ]
                ]
    in
    existing ++ new ++ [ add ]


viewPollGenericItemExisting : GenericOptionItem -> GenericPollEditorData -> ViewConfig a -> Html a
viewPollGenericItemExisting item pollData viewConfig =
    let
        hidden =
            (item.hidden && (not <| Set.member (optionIdInt item.optionId) pollData.unhiddenItems))
                || Set.member (optionIdInt item.optionId) pollData.hiddenItems
    in
    li [ class <| "poll-option-generic" ]
        [ input
            [ type_ "text"
            , value <| Maybe.withDefault item.value <| Dict.get (optionIdInt item.optionId) pollData.renamedItems
            , placeholder item.value
            , class <| "common-input poll-option-generic-input" ++ optClass hidden "poll-option-hidden"
            , onInput (viewConfig.outerMessage << RenameGenericPollItem item.optionId)
            ]
            []
        , text " "
        , button
            [ class "common-button common-icon-button"
            , onClick <|
                if hidden then
                    viewConfig.outerMessage <| UnhideGenericPollItem item.optionId

                else
                    viewConfig.outerMessage <| HideGenericPollItem item.optionId
            , title <|
                if hidden then
                    "Odkrýt"

                else
                    "Skrýt"
            ]
            [ if hidden then
                text "👁"

              else
                text "✗"
            ]
        ]


viewPollGenericItemNew : Int -> String -> GenericPollEditorData -> ViewConfig a -> Html a
viewPollGenericItemNew itemNumber itemValue pollData viewConfig =
    li [ class "poll-option-generic" ]
        [ input
            [ type_ "text"
            , value itemValue
            , class "common-input poll-option-generic-input"
            , onInput (viewConfig.outerMessage << SetNewGenericPollItem itemNumber)
            ]
            []
        , text " "
        , button
            [ class "common-button common-icon-button"
            , onClick (viewConfig.outerMessage <| RemoveGenericPollItem itemNumber)
            , disabled (itemNumber <= 1 && String.isEmpty itemValue && List.isEmpty pollData.originalItems)
            , title "Odstranit"
            ]
            [ text "✗" ]
        ]


viewPollDate : PollEditorModel -> CalendarStateModel -> DatePollEditorData -> ViewConfig a -> Html a
viewPollDate model state pollData viewConfig =
    div [ class "poll poll-date" ]
        [ div [ class "poll-header-row" ]
            [ div [ class "poll-header-name" ]
                [ text ("Hlasování " ++ String.fromInt (viewConfig.pollNumber + 1) ++ ": Datum") ]
            , viewDeletePollButton viewConfig
            ]
        , div [ class "poll-body" ]
            [ div [ class "poll-name-row" ]
                [ label []
                    [ span [ class "poll-name-label" ] [ text "Nadpis:" ]
                    , input
                        [ type_ "text"
                        , class "common-input poll-name-input"
                        , placeholder "např. Kdy se sejdeme?"
                        , value <| Maybe.withDefault model.originalTitle model.changedTitle
                        , onInput (viewConfig.outerMessage << SetPollTitle)
                        ]
                        []
                    ]
                , label []
                    [ span [ class "poll-description-label" ] [ text "Popis:" ]
                    , textarea
                        [ class "common-input poll-description-textarea"
                        , placeholder "Sem můžete napsat podrobnější informace o hlasování, ale nemusíte."
                        , value <| Maybe.withDefault model.originalDescription model.changedDescription
                        , onInput (viewConfig.outerMessage << SetPollDescription)
                        ]
                        []
                    ]
                ]
            , div [ class "poll-instructions" ]
                [ text "Označte v kalendáři termíny, o kterých se bude hlasovat." ]
            , viewDateCalendar state pollData viewConfig
            , viewPollDateItemTags state pollData viewConfig
            ]
        ]


viewDateCalendar : CalendarStateModel -> DatePollEditorData -> ViewConfig a -> Html a
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
            viewDateCalendarHeaderRow

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
            [ "Leden", "Únor", "Březen", "Duben", "Květen", "Červen", "Červenec", "Srpen", "Září", "Říjen", "Listopad", "Prosinec" ]

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
                , min "1970"
                , CommonView.onChange (viewConfig.outerMessage << SetCalendarYearDirect)
                ]
                []
            ]
        , div [ class "calendar-controls-buttons" ]
            [ button
                [ class "common-button common-input calendar-controls-buttons-today"
                , onClick (viewConfig.outerMessage <| SetCalendarMonth (monthFromDay viewConfig.today))
                ]
                [ text "Dnes" ]
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


viewDateCalendarHeaderRow : Html a
viewDateCalendarHeaderRow =
    let
        days =
            [ "Po", "Út", "St", "Čt", "Pá", "So", "Ne" ]

        dayToCell day =
            div [ class "calendar-cell calendar-header-cell" ] [ text day ]

        cells =
            List.map dayToCell days
    in
    div [ class "calendar-row calendar-header-row" ] cells


viewDateCalendarCell : CalendarStateModel -> DatePollEditorData -> ViewConfig a -> SDay -> Html a
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

        originalDateOptionItem =
            ListUtils.findFirst (\i -> i.value == sDay) pollData.originalItems

        originalSelected =
            case originalDateOptionItem of
                Just dateOptionItem ->
                    not dateOptionItem.hidden
                        && (not <| Set.member (optionIdInt dateOptionItem.optionId) pollData.hiddenItems)

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


viewPollDateItemTags : CalendarStateModel -> DatePollEditorData -> ViewConfig a -> Html a
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
                        " (skryté)"

                    else
                        ""
                   )

        tupleToTag (( year, month, _ ) as tuple) =
            let
                originalItem =
                    ListUtils.findFirst (\i -> Just i.value == dayFromTuple tuple) pollData.originalItems

                isHidden item =
                    (not item.hidden && Set.member (optionIdInt item.optionId) pollData.hiddenItems)
                        || (item.hidden && (not <| Set.member (optionIdInt item.optionId) pollData.unhiddenItems))

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
                [ div [ class "poll-date-tag-info" ] [ text "nic nevybráno :-(" ] ]

            else
                []
    in
    div [ class "poll-date-tags" ]
        ((div [] [ text "Přehled možností:" ] :: tags) ++ info)
