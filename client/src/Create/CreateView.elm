module Create.CreateView exposing (view)

import Common.CommonView exposing (viewBoxInfo)
import Common.Header exposing (headerLogo)
import Create.CreateModel exposing (CreatedProjectInfo, Model, Msg(..))
import Html exposing (Html, a, b, button, div, h2, header, input, label, p, span, text)
import Html.Attributes exposing (attribute, class, disabled, href, placeholder, tabindex, type_, value)
import Html.Events exposing (onClick, onInput)
import PollEditor.PollEditorModel exposing (CandidatesEditor(..))
import PollEditor.PollEditorView exposing (viewPollEditor)
import Set
import Translations.Translation exposing (Translation)
import Translations.TranslationsView exposing (translationsView)


view : Model -> Html Msg
view model =
    let
        content =
            case model.created of
                Nothing ->
                    viewEditing model

                Just projectInfo ->
                    viewCreated projectInfo model
    in
    div
        [ attribute "translate" "no", class "notranslate" ]
        [ header [] [ headerLogo ]
        , div [ class "project" ] [ div [ class "width" ] [ content ] ]
        ]


viewEditing : Model -> Html Msg
viewEditing model =
    div []
        [ translationsView model.translation SetTranslation
        , h2 [] [ text model.translation.create.newProjectHeader ]
        , label []
            [ span [ class "project-title-label" ] [ text model.translation.common.projectTitleLabel ]
            , input [ type_ "text", class "project-title common-input", placeholder model.translation.common.projectTitlePlaceholder, onInput SetTitle, value model.title ] []
            ]
        , viewBoxInfo model.translation.create.infoText
        , div [ class "polls" ]
            (List.indexedMap
                (\i p ->
                    viewPollEditor p
                        { today = model.today
                        , outerMessage = EditPoll i
                        , removePollMessage = Just <| RemovePoll i
                        , pollNumber = i
                        , translation = model.translation
                        }
                )
                model.polls
            )
        , if List.isEmpty model.polls then
            viewChooseFirstPoll model.translation

          else
            div [ class "add-poll-line" ]
                [ text model.translation.create.addPollFirstPart
                , b [] [ text model.translation.create.addPollBoldPart ]
                , text model.translation.create.addPollLastPart
                , span [ class "nowrap" ]
                    [ button [ class "common-button common-button-bigger colors-add common-add-icon add-poll-button add-poll-generic", onClick AddGenericPoll ]
                        [ text model.translation.common.pollTypeGeneric ]
                    , text " "
                    , button [ class "common-button common-button-bigger colors-add common-add-icon add-poll-button add-poll-date", onClick AddDatePoll ]
                        [ text model.translation.common.pollTypeDate ]
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


viewChooseFirstPoll : Translation -> Html Msg
viewChooseFirstPoll translation =
    div []
        [ div [ class "polls-empty-add" ]
            [ button [ class "polls-empty-add-button", onClick AddDatePoll, tabindex 0 ] [ text <| "+ " ++ translation.common.pollTypeDate ]
            , div [ class "polls-empty-add-description" ] [ text translation.create.pollDescriptionDate ]
            ]
        , div [ class "polls-empty-add" ]
            [ button [ class "polls-empty-add-button", onClick AddGenericPoll, tabindex 0 ] [ text <| "+ " ++ translation.common.pollTypeGeneric ]
            , div [ class "polls-empty-add-description" ] [ text translation.create.pollDescriptionGeneric ]
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
                    model.translation.common.untitled

                else
                    model.title
            ]
        , div []
            [ div []
                [ p [ class "project-created-info-main" ] [ text model.translation.create.projectCreatedText ]
                , p [] [ text model.translation.create.projectCreatedInfo1 ]
                , p [] [ text model.translation.create.projectCreatedInfo2 ]
                ]
            , div [ class "project-created-link-box" ]
                [ a [ class "project-created-link", href url ]
                    [ span [] [ text urlBase ]
                    , span [ class "project-created-link-secret" ] [ text secretKey ]
                    ]
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

        pollValid pollEditorModel =
            case pollEditorModel.candidatesEditor of
                DateCandidatesEditor { data } ->
                    not (Set.isEmpty data.addedItems)

                TextCandidatesEditor { addedItems } ->
                    not (List.isEmpty addedItems) && genericPollValid addedItems

        allValid =
            List.all pollValid model.polls

        disabledVal =
            empty || not allValid || model.wait

        buttonText =
            if model.wait then
                [ text model.translation.common.waitPlease ]

            else
                [ text <| model.translation.create.createProjectWithNPolls <| List.length model.polls ]
    in
    button [ class "submit-button common-button colors-add", disabled disabledVal, onClick Persist ]
        buttonText
