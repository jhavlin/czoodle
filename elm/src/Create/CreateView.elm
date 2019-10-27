module Create.CreateView exposing (view)

import Browser
import Browser.Dom
import Common.CommonView exposing (..)
import Create.CreateModel exposing (..)
import Html exposing (Html, a, b, button, div, input, label, li, ol, option, p, select, span, text, textarea)
import Html.Attributes exposing (class, disabled, href, min, placeholder, selected, tabindex, title, type_, value)
import Html.Events exposing (onClick, onInput, onMouseEnter, onMouseLeave)
import SDate.SDate exposing (..)
import Set exposing (..)
import Task


view model =
    case model.created of
        Nothing ->
            viewEditing model

        Just projectInfo ->
            viewCreated projectInfo model


viewEditing model =
    div []
        [ label []
            [ span [ class "project-title-label" ] [ text "Název:" ]
            , input [ type_ "text", class "project-title", placeholder "např. Teambuilding, dárek pro tetu, nebo třeba sraz baletek", onInput SetTitle, value model.title ] []
            ]
        , if List.isEmpty model.polls then
            viewEmptyInfo

          else
            div [ class "polls" ] (List.indexedMap (viewPoll model) model.polls)
        , if List.isEmpty model.polls then
            viewChooseFirstPoll

          else
            div [ class "add-poll-line" ]
                [ text "Přidat "
                , b [] [ text "hlasování" ]
                , text " pro: "
                , span [ class "nowrap" ]
                    [ button [ class "common-button common-button-bigger colors-add common-add-icon add-poll-button add-poll-generic", onClick AddGenericPoll ] [ text "Obecné" ]
                    , text " "
                    , button [ class "common-button common-button-bigger colors-add common-add-icon add-poll-button add-poll-date", onClick AddDatePoll ] [ text "Datum" ]
                    ]
                ]
        , case model.created of
            Nothing ->
                div [ class "submit-row" ]
                    [ submitButton model
                    ]

            Just { projectKey, secretKey } ->
                div [] [ text "created", text projectKey, text secretKey ]
        ]


viewEmptyInfo =
    div
        [ class "polls-empty-info" ]
        [ div [ class "polls-empty-info-icon" ] [ text "i" ]
        , div [ class "polls-empty-info-text" ] [ text "Projekt obsahuje jedno či více hlasování různých typů." ]
        ]


viewChooseFirstPoll =
    div []
        [ a [ class "polls-empty-add", onClick AddDatePoll, tabindex 0 ]
            [ div [ class "polls-empty-add-title" ] [ text "+ Datum" ]
            , div [ class "polls-empty-add-description" ] [ text "Když se rozhoduje o\u{00A0}tom KDY." ]
            ]
        , a [ class "polls-empty-add", onClick AddGenericPoll, tabindex 0 ]
            [ div [ class "polls-empty-add-title" ] [ text "+ Obecné" ]
            , div [ class "polls-empty-add-description" ] [ text "Když se rozhoduje o\u{00A0}tom CO, KDO, KAM nebo KDE." ]
            ]
        ]


viewCreated { projectKey, secretKey } model =
    let
        urlBase =
            String.concat [ model.baseUrl, "/v01/vote.html#", projectKey, "/" ]

        url =
            String.concat [ urlBase, secretKey ]
    in
    div []
        [ div [ class "project-created-title" ]
            [ text <|
                if model.title |> String.trim |> String.isEmpty then
                    "(bez názvu)"

                else
                    model.title
            ]
        , div []
            [ div []
                [ p [ class "project-created-info-main" ] [ text "Hurá. Projekt byl vytvořen. Tento odkaz si zkopírujte a pošlete všem hlasujícím!" ]
                , p [] [ text "Odkaz obsahuje dešifrovací klíč. Pokud o něj přijdete, nebudete moci k hlasování přistupovat." ]
                , p [] [ text "Na server se posílají pouze zašifrovaná data. Bez dešifrovacího klíče jsou bezcenná. Tak ho neztraťte ;-)" ]
                ]
            , a [ class "project-created-link", href url ]
                [ span [] [ text urlBase ]
                , span [ class "project-created-link-secret" ] [ text secretKey ]
                ]
            ]
        ]


optClass : Bool -> String -> String
optClass present name =
    if present then
        " " ++ name

    else
        ""


viewPoll : Model -> Int -> NewPoll -> Html Msg
viewPoll model num { title, description, def } =
    case def of
        NewGenericPollModel genericDef ->
            viewPollGeneric num title description genericDef

        NewDatePollModel state dateDef ->
            viewPollDate num title description state dateDef model.today


viewPollGeneric : Int -> String -> String -> NewGenericPollData -> Html Msg
viewPollGeneric num name description { items } =
    div [ class "poll poll-generic" ]
        [ div [ class "poll-header-row" ]
            [ div [ class "poll-header-name" ] [ text ("Hlasování " ++ String.fromInt (num + 1) ++ ": Obecné") ]
            , div [ class "poll-header-delete" ]
                [ button [ class "delete-poll-button common-button common-input", onClick (RemovePoll num), title "Odstranit hlasování" ] [ text "✗" ] ]
            ]
        , div [ class "poll-body" ]
            [ div [ class "poll-name-row" ]
                [ label []
                    [ span [ class "poll-name-label" ] [ text "Nadpis:" ]
                    , input [ type_ "text", class "common-input poll-name-input", placeholder "např. Co za dárek? nebo Jaká hospoda?", value name, onInput (SetPollTitle num) ] []
                    ]
                , label []
                    [ span [ class "poll-description-label" ] [ text "Popis:" ]
                    , textarea [ class "common-input poll-description-textarea", placeholder "Sem můžete napsat podrobnější informace o hlasování, ale nemusíte.", value description, onInput (SetPollDescription num) ] []
                    ]
                ]
            , div [ class "poll-instructions" ] [ text "Zadejte možnosti, o kterých se bude hlasovat (alespoň dvě)." ]
            , div [ class "poll-options" ]
                [ div [ class "poll-options-header" ] [ text "Možnosti:" ]
                , ol [ class "poll-options-list" ] (viewPollGenericItems num items)
                ]
            ]
        ]


viewPollGenericItems : Int -> List String -> List (Html Msg)
viewPollGenericItems pollNumber items =
    let
        existing =
            List.indexedMap (\itemNumber item -> viewPollGenericItem pollNumber itemNumber item) items

        add =
            li [ class "poll-option-generic" ]
                [ button
                    [ onClick (AddGenericPollItem pollNumber)
                    , class "common-button common-button-bigger colors-neutral common-add-icon"
                    ]
                    [ text "Přidat možnost" ]
                ]
    in
    existing ++ [ add ]


viewPollGenericItem : Int -> Int -> String -> Html Msg
viewPollGenericItem pollNumber itemNumber itemValue =
    li [ class "poll-option-generic" ]
        [ input
            [ type_ "text"
            , value itemValue
            , class "common-input poll-option-generic-input"
            , onInput (SetGenericPollItem pollNumber itemNumber)
            ]
            []
        , text " "
        , button
            [ class "common-button common-icon-button"
            , onClick (RemoveGenericPollItem pollNumber itemNumber)
            , disabled (itemNumber <= 1 && String.isEmpty itemValue)
            , title "Odstranit"
            ]
            [ text "✗" ]
        ]


viewPollDate : Int -> String -> String -> CalendarStateModel -> NewDatePollData -> SDay -> Html Msg
viewPollDate num name description state pollData today =
    div [ class "poll poll-date" ]
        [ div [ class "poll-header-row" ]
            [ div [ class "poll-header-name" ] [ text ("Hlasování " ++ String.fromInt (num + 1) ++ ": Datum") ]
            , div [ class "poll-header-delete" ]
                [ button [ class "delete-poll-button common-button common-input", onClick (RemovePoll num), title "Odstranit hlasování" ] [ text "✗" ] ]
            ]
        , div [ class "poll-body" ]
            [ div [ class "poll-name-row" ]
                [ label []
                    [ span [ class "poll-name-label" ] [ text "Nadpis:" ]
                    , input [ type_ "text", class "common-input poll-name-input", placeholder "např. Kdy se sejdeme?", value name, onInput (SetPollTitle num) ] []
                    ]
                , label []
                    [ span [ class "poll-description-label" ] [ text "Popis:" ]
                    , textarea [ class "common-input poll-description-textarea", placeholder "Sem můžete napsat podrobnější informace o hlasování, ale nemusíte.", value description, onInput (SetPollDescription num) ] []
                    ]
                ]
            , div [ class "poll-instructions" ] [ text "Označte v kalendáři termíny, o kterých se bude hlasovat (alespoň dva)." ]
            , viewDateCalendar num state pollData today
            , viewPollDateItemTags num state pollData
            ]
        ]


viewDateCalendar : Int -> CalendarStateModel -> NewDatePollData -> SDay -> Html Msg
viewDateCalendar num state pollData today =
    let
        weeks =
            weeksInMonth state.month

        cellFn =
            viewDateCalendarCell num state pollData

        weekRow days =
            div [ class "calendar-row" ] (List.map cellFn days)

        controlsRow =
            viewDateCalendarControls num state today

        headerRow =
            viewDateCalendarHeaderRow

        rows =
            List.map weekRow weeks
    in
    div [ class "calendar-table" ] (controlsRow :: headerRow :: rows)


viewDateCalendarControls : Int -> CalendarStateModel -> SDay -> Html Msg
viewDateCalendarControls num state today =
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
                , onInput (SetCalendarMonthDirect num)
                ]
                options
            , input
                [ class "common-input common-group-last calendar-controls-year"
                , type_ "number"
                , value (String.fromInt year)
                , min "1970"
                , onChange (SetCalendarYearDirect num)
                ]
                []
            ]
        , div [ class "calendar-controls-buttons" ]
            [ button
                [ class "common-button common-input calendar-controls-buttons-today"
                , onClick (SetCalendarMonth num (monthFromDay today))
                ]
                [ text "Dnes" ]
            , text " "
            , button
                [ class "common-button common-wide common-input common-group-first"
                , onClick (SetCalendarMonth num (prevMonth state.month))
                ]
                [ text " < " ]
            , button
                [ class "common-button common-wide common-input common-group-last"
                , onClick (SetCalendarMonth num (nextMonth state.month))
                ]
                [ text " > " ]
            ]
        ]


viewDateCalendarHeaderRow : Html Msg
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


viewDateCalendarCell : Int -> CalendarStateModel -> NewDatePollData -> SDay -> Html Msg
viewDateCalendarCell num state pollData sDay =
    let
        dayTuple =
            dayToTuple sDay

        ( year, month, date ) =
            dayTuple

        ( _, activeMonth ) =
            monthToTuple state.month

        active =
            month == activeMonth

        selected =
            Set.member dayTuple pollData.items

        onClickAction =
            if selected then
                RemoveDatePollItem num dayTuple

            else
                AddDatePollItem num dayTuple

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
        , onMouseEnter <| SetHighlightedDay num (Just dayTuple)
        , onMouseLeave <| SetHighlightedDay num Nothing
        , tabindex 0
        ]
        [ String.fromInt date |> text
        ]


viewPollDateItemTags : Int -> CalendarStateModel -> NewDatePollData -> Html Msg
viewPollDateItemTags num state pollData =
    let
        ( shownYear, shownMonth ) =
            monthToTuple state.month

        tupleAsText ( year, month, date ) =
            String.fromInt date
                ++ ". "
                ++ String.fromInt month
                ++ "."

        tupleToTag (( year, month, date ) as tuple) =
            div
                [ class "poll-date-tag"
                , onMouseEnter <| SetHighlightedDay num (Just tuple)
                , onMouseLeave <| SetHighlightedDay num Nothing
                ]
                [ div
                    [ class
                        ("poll-date-tag-name"
                            ++ optClass (( shownYear, shownMonth ) /= ( year, month )) "poll-date-tag-name-active"
                            ++ optClass (state.highlightedDay == Just tuple) "poll-date-tag-name-highlighted"
                        )
                    , onClick (Maybe.withDefault NoOp (Maybe.map (\m -> SetCalendarMonth num m) (monthFromTuple ( year, month ))))
                    ]
                    [ text <| tupleAsText tuple ]
                , div
                    [ class "poll-date-tag-delete"
                    , onClick (RemoveDatePollItem num tuple)
                    ]
                    [ text "✗" ]
                ]

        tags =
            List.map tupleToTag <| Set.toList pollData.items

        info =
            if Set.isEmpty pollData.items then
                [ div [ class "poll-date-tag-info" ] [ text "nic nevybráno :-(" ] ]

            else
                []
    in
    div [ class "poll-date-tags" ]
        ([ div [] [ text "Přehled možností:" ] ] ++ tags ++ info)


submitButton : Model -> Html Msg
submitButton model =
    let
        empty =
            List.isEmpty model.polls

        genericPollValid items =
            List.all (\s -> not (String.isEmpty <| String.trim s)) items

        pollValid { title, def } =
            case def of
                NewDatePollModel _ { items } ->
                    not (Set.isEmpty items)

                NewGenericPollModel { items } ->
                    not (List.isEmpty items) && genericPollValid items

        allValid =
            List.all pollValid model.polls

        disabledVal =
            empty || not allValid || model.wait

        buttonText =
            if model.wait then
                [ text "Čekejte, prosím." ]

            else
                [ text "Vytvořit projekt (", text (String.fromInt <| List.length model.polls), text " hlasování)" ]
    in
    button [ class "submit-button common-button colors-add", disabled disabledVal, onClick Persist ]
        buttonText
