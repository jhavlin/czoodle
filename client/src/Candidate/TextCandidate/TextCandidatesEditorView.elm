module Candidate.TextCandidate.TextCandidatesEditorView exposing (ViewConfig, viewTextCandidatesEditor)

import Candidate.TextCandidate.TextCandidateData exposing (TextCandidateItem)
import Candidate.TextCandidate.TextCandidatesEditorModel exposing (TextCandidatesEditorModel, TextCandidatesEditorMsg(..))
import Common.CommonView exposing (optClass)
import Data.CandidateId exposing (candidateIdInt)
import Dict
import Html exposing (Html, button, div, input, li, ol, text)
import Html.Attributes exposing (class, disabled, placeholder, title, type_, value)
import Html.Events exposing (onClick, onInput)
import Set
import Translations.Translation exposing (Translation)


type alias ViewConfig outerMsg =
    { outerMessage : TextCandidatesEditorMsg -> outerMsg
    , translation : Translation
    }


viewTextCandidatesEditor : TextCandidatesEditorModel -> ViewConfig a -> Html a
viewTextCandidatesEditor model viewConfig =
    div []
        [ div [ class "poll-instructions" ]
            [ text viewConfig.translation.pollEditor.optionsInstructionsGeneric ]
        , div [ class "poll-options" ]
            [ div [ class "poll-options-header" ] [ text viewConfig.translation.common.pollOptionsLabel ]
            , ol [ class "poll-options-list" ] (viewPollGenericItems model viewConfig)
            ]
        ]


viewPollGenericItems : TextCandidatesEditorModel -> ViewConfig a -> List (Html a)
viewPollGenericItems model viewConfig =
    let
        existing =
            List.map (\item -> viewPollGenericItemExisting item model viewConfig) model.originalItems

        new =
            List.indexedMap (\itemNumber item -> viewPollGenericItemNew itemNumber item model viewConfig) model.addedItems

        add =
            li [ class "poll-option-generic" ]
                [ button
                    [ onClick (viewConfig.outerMessage AddGenericPollItem)
                    , class "common-button common-button-bigger colors-neutral common-add-icon"
                    ]
                    [ text viewConfig.translation.pollEditor.addOption ]
                ]
    in
    existing ++ new ++ [ add ]


viewPollGenericItemExisting : TextCandidateItem -> TextCandidatesEditorModel -> ViewConfig a -> Html a
viewPollGenericItemExisting item model viewConfig =
    let
        hidden =
            (item.hidden && (not <| Set.member (candidateIdInt item.candidateId) model.unhiddenItems))
                || Set.member (candidateIdInt item.candidateId) model.hiddenItems
    in
    li [ class <| "poll-option-generic" ]
        [ input
            [ type_ "text"
            , value <| Maybe.withDefault item.value <| Dict.get (candidateIdInt item.candidateId) model.renamedItems
            , placeholder item.value
            , class <| "common-input poll-option-generic-input" ++ optClass hidden "poll-option-hidden"
            , onInput (viewConfig.outerMessage << RenameGenericPollItem item.candidateId)
            ]
            []
        , text " "
        , button
            [ class "common-button common-icon-button"
            , onClick <|
                if hidden then
                    viewConfig.outerMessage <| UnhideGenericPollItem item.candidateId

                else
                    viewConfig.outerMessage <| HideGenericPollItem item.candidateId
            , title <|
                if hidden then
                    viewConfig.translation.pollEditor.unhide

                else
                    viewConfig.translation.pollEditor.hide
            ]
            [ if hidden then
                text "👁"

              else
                text "✗"
            ]
        ]


viewPollGenericItemNew : Int -> String -> TextCandidatesEditorModel -> ViewConfig a -> Html a
viewPollGenericItemNew itemNumber itemValue model viewConfig =
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
            , disabled (itemNumber == 0 && String.isEmpty itemValue && List.isEmpty model.originalItems)
            , title viewConfig.translation.common.remove
            ]
            [ text "✗" ]
        ]
