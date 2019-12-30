module Create.CreateView exposing (view)

import Common.CommonView exposing (viewBoxInfo)
import Create.CreateModel exposing (CreatedProjectInfo, Model, Msg(..))
import Html exposing (Html, a, b, button, div, input, label, p, span, text)
import Html.Attributes exposing (class, disabled, href, placeholder, tabindex, type_, value)
import Html.Events exposing (onClick, onInput)
import PollEditor.PollEditorModel exposing (PollEditor(..))
import PollEditor.PollEditorView exposing (viewPoll)
import Set


view : Model -> Html Msg
view model =
    case model.created of
        Nothing ->
            viewEditing model

        Just projectInfo ->
            viewCreated projectInfo model


viewEditing : Model -> Html Msg
viewEditing model =
    div []
        [ label []
            [ span [ class "project-title-label" ] [ text "Název:" ]
            , input [ type_ "text", class "project-title", placeholder "např. Teambuilding, dárek pro tetu, nebo třeba sraz baletek", onInput SetTitle, value model.title ] []
            ]
        , viewBoxInfo "Projekt obsahuje jedno či více hlasování různých typů."
        , div [ class "polls" ]
            (List.indexedMap (\i p -> viewPoll p { today = model.today, outerMessage = EditPoll i, removePollMessage = Just <| RemovePoll i, pollNumber = i }) model.polls)
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


viewChooseFirstPoll : Html Msg
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


viewCreated : CreatedProjectInfo -> Model -> Html Msg
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


submitButton : Model -> Html Msg
submitButton model =
    let
        empty =
            List.isEmpty model.polls

        genericPollValid items =
            List.all (\s -> not (String.isEmpty <| String.trim s)) items

        pollValid { editor } =
            case editor of
                DatePollEditor _ { addedItems } ->
                    not (Set.isEmpty addedItems)

                GenericPollEditor { addedItems } ->
                    not (List.isEmpty addedItems) && genericPollValid addedItems

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
