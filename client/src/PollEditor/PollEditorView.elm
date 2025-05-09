module PollEditor.PollEditorView exposing
    ( ViewConfig
    , viewPollEditor
    )

import Candidate.DateCandidate.DateCandidatesEditorView as DateCandidatesEditorView
import Candidate.DateCandidate.SDate exposing (SDay)
import Candidate.TextCandidate.TextCandidatesEditorView as TextCandidatesEditorView
import Html exposing (Html, button, div, input, label, span, text, textarea)
import Html.Attributes exposing (class, placeholder, title, type_, value)
import Html.Events exposing (onClick, onInput)
import PollEditor.PollEditorModel
    exposing
        ( CandidatesEditor(..)
        , CandidatesEditorMsg(..)
        , PollEditorModel
        , PollEditorMsg(..)
        )
import Translations.Translation exposing (Translation)


type alias ViewConfig outerMsg =
    { outerMessage : PollEditorMsg -> outerMsg
    , removePollMessage : Maybe outerMsg
    , today : SDay
    , pollNumber : Int
    , translation : Translation
    }


viewDeletePollButton : ViewConfig a -> Html a
viewDeletePollButton viewConfig =
    case viewConfig.removePollMessage of
        Just msg ->
            div [ class "poll-header-delete" ]
                [ button
                    [ class "delete-poll-button common-button common-input"
                    , onClick msg
                    , title viewConfig.translation.pollEditor.removePoll
                    ]
                    [ text "✗" ]
                ]

        Nothing ->
            div [] []


viewPollEditor : PollEditorModel -> ViewConfig a -> Html a
viewPollEditor model viewConfig =
    div [ class <| String.concat [ "poll", " ", pollClass model ] ]
        [ div [ class "poll-header-row" ]
            [ div [ class "poll-header-name" ]
                [ text <| viewConfig.translation.pollEditor.editorTitleGeneric <| viewConfig.pollNumber + 1 ]
            , viewDeletePollButton viewConfig
            ]
        , div [ class "poll-body" ]
            [ div [ class "poll-name-row" ]
                [ label []
                    [ span [ class "poll-name-label" ] [ text viewConfig.translation.common.pollTitleLabel ]
                    , input
                        [ type_ "text"
                        , class "common-input poll-name-input"
                        , placeholder viewConfig.translation.pollEditor.pollTitlePlaceholderGeneric
                        , value <| Maybe.withDefault model.originalTitle model.changedTitle
                        , onInput (viewConfig.outerMessage << SetPollTitle)
                        ]
                        []
                    ]
                , label []
                    [ span [ class "poll-description-label" ] [ text viewConfig.translation.common.pollDescriptionLabel ]
                    , textarea
                        [ class "common-input poll-description-textarea"
                        , placeholder viewConfig.translation.pollEditor.pollDescriptionPlaceholder
                        , value <| Maybe.withDefault model.originalDescription model.changedDescription
                        , onInput (viewConfig.outerMessage << SetPollDescription)
                        ]
                        []
                    ]
                ]
            , viewCandidatesEditor model viewConfig
            ]
        ]


viewCandidatesEditor : PollEditorModel -> ViewConfig a -> Html a
viewCandidatesEditor model viewConfig =
    case model.candidatesEditor of
        DateCandidatesEditor innerModel ->
            let
                innerConfig : DateCandidatesEditorView.ViewConfig a
                innerConfig =
                    { outerMessage = \m -> viewConfig.outerMessage (InnerMsgCandidates (InnerMsgDate m))
                    , today = viewConfig.today
                    , translation = viewConfig.translation
                    }
            in
            DateCandidatesEditorView.viewDateCandidatesEditor innerModel innerConfig

        TextCandidatesEditor innerModel ->
            let
                innerConfig : TextCandidatesEditorView.ViewConfig a
                innerConfig =
                    { outerMessage = \m -> viewConfig.outerMessage (InnerMsgCandidates (InnerMsgText m))
                    , translation = viewConfig.translation
                    }
            in
            TextCandidatesEditorView.viewTextCandidatesEditor innerModel innerConfig


pollClass : PollEditorModel -> String
pollClass model =
    case model.candidatesEditor of
        DateCandidatesEditor _ ->
            "poll-date"

        TextCandidatesEditor _ ->
            "poll-generic"
