port module CreateProject exposing (Model, Msg(..), init, main, subscriptions, update, view)

import Browser
import Browser.Dom
import Decoders exposing (decodeCreateFlags)
import Encoders exposing (encodeDayTuple)
import Html exposing (Html, a, b, button, div, input, label, li, ol, option, p, select, span, text)
import Html.Attributes exposing (class, disabled, href, min, placeholder, selected, tabindex, title, type_, value)
import Html.Events exposing (on, onClick, onInput, onMouseEnter, onMouseLeave)
import Json.Decode as D
import Json.Encode as E
import ListUtils exposing (removeIndex)
import SDate.SDate exposing (..)
import Set exposing (..)
import Task


port persist : E.Value -> Cmd msg


port createdProjectInfo : (D.Value -> msg) -> Sub msg


type Msg
    = SetTitle String
    | AddGenericPoll
    | AddDatePoll
    | RemovePoll Int
    | SetPollTitle Int String
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


type alias DayTuple =
    ( Int, Int, Int )


type alias PollData =
    { title : String
    , def : PollDef
    }


type alias CalendarStateData =
    { month : SMonth
    , highlightedDay : Maybe DayTuple
    , today : SDay
    }


type alias GenericPollData =
    { items : List String }


type alias DatePollData =
    { items : Set DayTuple }


type Poll
    = Poll PollData


type PollDef
    = DatePollDef CalendarStateData DatePollData
    | GenericPollDef GenericPollData


type alias CreatedProjectInfo =
    { projectKey : String
    , secretKey : String
    }


type alias Model =
    { title : String
    , polls : List Poll
    , today : SDay
    , wait : Bool
    , created : Maybe CreatedProjectInfo
    , baseUrl : String
    }



---- Init ----


init : D.Value -> ( Model, Cmd Msg )
init jsonFlags =
    let
        flagsResult =
            D.decodeValue decodeCreateFlags jsonFlags

        { today, baseUrl } =
            Result.withDefault { today = defaultDay, baseUrl = "" } flagsResult
    in
    ( { title = ""
      , polls = [ emptyDatePoll today ]
      , today = today
      , baseUrl = baseUrl
      , wait = False
      --   , created = Just { projectKey = "196u6", secretKey = "KXM8c0jaaZwJ3IRsTw0uRtJE9zY-l3-WQ8dnOnl07Iw" }
      , created = Nothing
      }
    , Cmd.none
    )



---- Subscriptions ----


subscriptions : Model -> Sub Msg
subscriptions _ =
    let
        decoder =
            D.map2 CreatedProjectInfo
                (D.field "projectKey" D.string)
                (D.field "secretKey" D.string)

        decodeCreatedProjectInfo v =
            D.decodeValue decoder v

        decoderResult v =
            case decodeCreatedProjectInfo v of
                Ok value ->
                    value

                Err _ ->
                    { projectKey = "error", secretKey = "error" }
    in
    createdProjectInfo (\v -> ProjectCreated (decoderResult v))



---- Update ----


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        SetTitle newTitle ->
            ( { model | title = newTitle }, Cmd.none )

        AddGenericPoll ->
            ( { model | polls = model.polls ++ [ emptyGenericPoll ] }, Cmd.none )

        AddDatePoll ->
            ( { model | polls = model.polls ++ [ emptyDatePoll model.today ] }, Cmd.none )

        RemovePoll num ->
            ( { model | polls = ListUtils.removeIndex num model.polls }, Cmd.none )

        SetPollTitle num title ->
            ( { model | polls = ListUtils.changeIndex (setPollTitle title) num model.polls }, Cmd.none )

        SetGenericPollItem num itemNumber itemVal ->
            ( doWithGenericPoll (setGenericItem itemNumber itemVal) model num, Cmd.none )

        AddGenericPollItem num ->
            ( doWithGenericPoll addGenericItem model num, Cmd.none )

        RemoveGenericPollItem num itemNumber ->
            ( doWithGenericPoll (removeGenericItem itemNumber) model num, Cmd.none )

        AddDatePollItem num dayTuple ->
            ( doWithDatePoll (\data -> { data | items = Set.insert dayTuple data.items }) model num, Cmd.none )

        RemoveDatePollItem num dayTuple ->
            ( doWithDatePoll (\data -> { data | items = Set.remove dayTuple data.items }) model num, Cmd.none )

        SetCalendarMonth num sMonth ->
            ( doWithDatePollState (\state -> { state | month = sMonth }) model num, Cmd.none )

        SetCalendarMonthDirect num str ->
            ( doWithDatePollState (setCalendarMonthDirect str) model num, Cmd.none )

        SetCalendarYearDirect num str ->
            ( doWithDatePollState (setCalendarYearDirect str) model num, Cmd.none )

        SetHighlightedDay num maybeTuple ->
            ( doWithDatePollState (\state -> { state | highlightedDay = maybeTuple }) model num, Cmd.none )

        Persist ->
            ( { model | wait = True }, persist <| encodeModel model )

        ProjectCreated projectInfo ->
            let
                scroll id = Browser.Dom.getViewportOf id
                    |> Task.andThen (\info -> Browser.Dom.setViewport 0 info.viewport.y)
                    |> Task.attempt (\_ -> NoOp)
            in
            ( { model | created = Just projectInfo }, scroll "project" )



doWithGenericPoll : (GenericPollData -> GenericPollData) -> Model -> Int -> Model
doWithGenericPoll fn model pollNumber =
    let
        checkAndDo (Poll pollData) =
            case pollData.def of
                GenericPollDef genericPollData ->
                    Poll { pollData | def = GenericPollDef (fn genericPollData) }

                _ ->
                    Poll pollData

        polls =
            ListUtils.changeIndex checkAndDo pollNumber model.polls
    in
    { model | polls = polls }


doWithDatePoll : (DatePollData -> DatePollData) -> Model -> Int -> Model
doWithDatePoll fn model pollNumber =
    let
        checkAndDo (Poll pollData) =
            case pollData.def of
                DatePollDef state datePollData ->
                    Poll { pollData | def = DatePollDef state (fn datePollData) }

                _ ->
                    Poll pollData

        polls =
            ListUtils.changeIndex checkAndDo pollNumber model.polls
    in
    { model | polls = polls }


doWithDatePollState : (CalendarStateData -> CalendarStateData) -> Model -> Int -> Model
doWithDatePollState fn model pollNumber =
    let
        checkAndDo (Poll pollData) =
            case pollData.def of
                DatePollDef state datePollData ->
                    Poll { pollData | def = DatePollDef (fn state) datePollData }

                _ ->
                    Poll pollData

        polls =
            ListUtils.changeIndex checkAndDo pollNumber model.polls
    in
    { model | polls = polls }


emptyGenericPoll : Poll
emptyGenericPoll =
    Poll { title = "", def = GenericPollDef { items = [ "", "" ] } }


emptyDatePoll : SDay -> Poll
emptyDatePoll today =
    let
        state =
            { month = monthFromDay today, highlightedDay = Nothing, today = today }

        def =
            DatePollDef state { items = Set.empty }
    in
    Poll { title = "", def = def }


setPollTitle : String -> Poll -> Poll
setPollTitle newTitle (Poll pollDef) =
    Poll { pollDef | title = newTitle }


addGenericItem : GenericPollData -> GenericPollData
addGenericItem data =
    { data | items = data.items ++ [ "" ] }


setGenericItem : Int -> String -> GenericPollData -> GenericPollData
setGenericItem itemNumber newValue data =
    { data | items = ListUtils.changeIndex (\_ -> newValue) itemNumber data.items }


removeGenericItem : Int -> GenericPollData -> GenericPollData
removeGenericItem itemNumber data =
    let
        newItems =
            if List.length data.items > 2 then
                ListUtils.removeIndex itemNumber data.items

            else
                ListUtils.changeIndex (\_ -> "") itemNumber data.items
    in
    { data | items = newItems }


setCalendarMonthDirect : String -> CalendarStateData -> CalendarStateData
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


setCalendarYearDirect : String -> CalendarStateData -> CalendarStateData
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



---- Transforms ----


encodeModel : Model -> E.Value
encodeModel model =
    let
        encodeTupleWithString ( i, s ) =
            E.object [ ( "id", E.int (i + 1) ), ( "value", E.string s ) ]

        encodeStringsWithId items =
            E.list encodeTupleWithString (List.indexedMap Tuple.pair items)

        encodeTupleWithDay ( i, d ) =
            E.object [ ( "id", E.int (i + 1) ), ( "value", encodeDayTuple d ) ]

        encodeDaysWithId items =
            E.list encodeTupleWithDay (List.indexedMap Tuple.pair items)

        encodePollDef def =
            case def of
                GenericPollDef { items } ->
                    E.object
                        [ ( "type", E.string "generic" )
                        , ( "items", encodeStringsWithId items )
                        , ( "lastItemId", E.int <| List.length items )
                        ]

                DatePollDef _ { items } ->
                    E.object
                        [ ( "type", E.string "date" )
                        , ( "items", encodeDaysWithId (Set.toList items) )
                        , ( "lastItemId", E.int <| Set.size items )
                        ]

        encodePoll ( index, Poll { title, def } ) =
            E.object
                [ ( "title", E.string title )
                , ( "def", encodePollDef def )
                , ( "id", E.int <| index + 1 )
                , ( "lastPersonId", E.int <| 0 )
                , ( "people", E.list E.string [] ) -- not actual strings, just preparing empty array
                ]
    in
    E.object
        [ ( "title", E.string model.title )
        , ( "polls", E.list encodePoll <| List.indexedMap Tuple.pair model.polls )
        , ( "lastPollId", E.int <| List.length model.polls )
        , ( "comments", E.list E.string [] ) -- not actual strings, just preparing empty array
        , ( "lastCommentId", E.int <| 0 )
        ]



---- View ----


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
            , input [ type_ "text", class "project-title", placeholder "Teambuilding, dárek pro tetu, nebo třeba sraz baletek", onInput SetTitle, value model.title ] []
            ]
        , div [ class "polls" ] (List.indexedMap (viewPoll model) model.polls)
        , div [ class "add-poll-line" ]
            [ text "Přidat "
            , b [] [ text "hlasování" ]
            , text " pro: "
            , span [ class "nowrap" ]
                [ button [ class "common-button colors-add common-add-icon add-poll-button add-poll-generic", onClick AddGenericPoll ] [ text "Obecné" ]
                , text " "
                , button [ class "common-button colors-add common-add-icon add-poll-button add-poll-date", onClick AddDatePoll ] [ text "Datum" ]
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
                , p [] [ text "Odkaz obsahuje dešifrovací klíč. Pokud o něj přijdete, nebudte moci k hlasování přistupovat." ]
                , p [] [ text "Na server se posílají pouze zašifrovaná data. Bez dešifrovacího klíče jsou bezcenná. Tak ho neztraťte ;-)" ]
                ]
            , a [ class "project-created-link", href url ]
                [ span [] [ text urlBase ]
                , span [ class "project-created-link-secret" ] [ text secretKey ]
                ]
            ]
        ]


onChange : (String -> msg) -> Html.Attribute msg
onChange handler =
    on "change" <| D.map handler <| D.at [ "target", "value" ] D.string


optClass : Bool -> String -> String
optClass present name =
    if present then
        " " ++ name

    else
        ""


viewPoll : Model -> Int -> Poll -> Html Msg
viewPoll model num (Poll { title, def }) =
    case def of
        GenericPollDef genericDef ->
            viewPollGeneric num title genericDef

        DatePollDef state dateDef ->
            viewPollDate num title state dateDef model.today


viewPollGeneric : Int -> String -> GenericPollData -> Html Msg
viewPollGeneric num name { items } =
    div [ class "poll poll-generic" ]
        [ div [ class "poll-header-row" ]
            [ div [ class "poll-header-name" ] [ text ("Hlasování " ++ String.fromInt (num + 1) ++ ": Obecné") ]
            , div [ class "poll-header-delete" ]
                [ button [ class "delete-poll-button common-button common-input", onClick (RemovePoll num), title "Odstranit hlasování" ] [ text "✗" ] ]
            ]
        , div [ class "poll-body" ]
            [ div [ class "poll-name-row" ]
                [ label []
                    [ span [ class "poll-name-label" ] [ text "Popis:" ]
                    , input [ type_ "text", class "common-input poll-name-input", placeholder "Co za dárek? nebo Jaká hospoda?", value name, onInput (SetPollTitle num) ] []
                    ]
                ]
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
                    ]
                    [ text "Přidat" ]
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


viewPollDate : Int -> String -> CalendarStateData -> DatePollData -> SDay -> Html Msg
viewPollDate num name state pollData today =
    div [ class "poll poll-date" ]
        [ div [ class "poll-header-row" ]
            [ div [ class "poll-header-name" ] [ text ("Hlasování " ++ String.fromInt (num + 1) ++ ": Datum") ]
            , div [ class "poll-header-delete" ]
                [ button [ class "delete-poll-button common-button common-input", onClick (RemovePoll num), title "Odstranit hlasování" ] [ text "✗" ] ]
            ]
        , div [ class "poll-body" ]
            [ div [ class "poll-name-row" ]
                [ label []
                    [ span [ class "poll-name-label" ] [ text "Popis:" ]
                    , input [ type_ "text", class "common-input poll-name-input", placeholder "Kdy se sejdeme?", value name, onInput (SetPollTitle num) ] []
                    ]
                ]
            , viewDateCalendar num state pollData today
            , viewPollDateItemTags num state pollData
            ]
        ]


viewDateCalendar : Int -> CalendarStateData -> DatePollData -> SDay -> Html Msg
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


viewDateCalendarControls : Int -> CalendarStateData -> SDay -> Html Msg
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


viewDateCalendarCell : Int -> CalendarStateData -> DatePollData -> SDay -> Html Msg
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


viewPollDateItemTags : Int -> CalendarStateData -> DatePollData -> Html Msg
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

        pollValid (Poll { title, def }) =
            case def of
                DatePollDef _ { items } ->
                    not (Set.isEmpty items)

                GenericPollDef { items } ->
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



---- Program ----


main : Program D.Value Model Msg
main =
    Browser.element { init = init, update = update, view = view, subscriptions = subscriptions }
