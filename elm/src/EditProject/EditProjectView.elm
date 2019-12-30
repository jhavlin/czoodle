module EditProject.EditProjectView exposing (view)

import Common.CommonView exposing (invisibleToClass, viewBoxInfo)
import Data.DataModel exposing (Project)
import EditProject.EditProjectModel exposing (ChangesInProjectDefinition, Msg(..))
import Html exposing (Html, a, button, div, input, text)
import Html.Attributes exposing (class, disabled, title, value)
import Html.Events exposing (onClick, onInput)
import PollEditor.PollEditorModel as PollEditorModel
import PollEditor.PollEditorView exposing (viewPoll)
import SDate.SDate exposing (SDay)


type alias ViewConfig outerMsg =
    { outerMessage : Msg -> outerMsg
    , switchBackMessage : Bool -> outerMsg
    , saveMessage : outerMsg
    , today : SDay
    }


view : Project -> ChangesInProjectDefinition -> ViewConfig outerMsg -> Html outerMsg
view project changesInProjectDefinition viewConfig =
    let
        { outerMessage, switchBackMessage } =
            viewConfig

        titleChanged =
            case changesInProjectDefinition.changedTitle of
                Nothing ->
                    False

                Just _ ->
                    True

        editorModels =
            List.map (\( _, m ) -> m) changesInProjectDefinition.pollEditorModels

        hasChanges =
            titleChanged || List.any PollEditorModel.isChanged editorModels

        wrap msg =
            \x -> outerMessage (msg x)

        pollEditorView index ( pollId, pollEditorModel ) =
            viewPoll pollEditorModel
                { outerMessage = viewConfig.outerMessage << ChangePoll pollId
                , removePollMessage = Nothing
                , today = viewConfig.today
                , pollNumber = index
                }

        editorViews =
            List.indexedMap pollEditorView changesInProjectDefinition.pollEditorModels
    in
    div [ class "vote-project" ]
        [ div [ class "vote-poll-center-outer" ]
            [ div [ class "vote-poll-center" ]
                [ div [ class "vote-poll-preferred-width vote-project-title-line" ]
                    [ input
                        [ class "vote-project-title"
                        , value <| Maybe.withDefault (Maybe.withDefault "" project.title) changesInProjectDefinition.changedTitle
                        , onInput <| wrap ChangeTitle
                        ]
                        []
                    , div [ class ("vote-project-edit-cell" ++ invisibleToClass hasChanges) ]
                        [ a
                            [ class "vote-project-edit-button"
                            , title "Přepnout zpět na hlasování"
                            , onClick <| switchBackMessage False
                            ]
                            [ text "✎" ]
                        ]
                    ]
                , viewBoxInfo "Změny by měly provádět pouze oprávněné osoby."
                , div [] editorViews
                , viewButtons hasChanges viewConfig
                ]
            ]
        ]


viewButtons : Bool -> ViewConfig outerMsg -> Html outerMsg
viewButtons hasChanges viewConfig =
    div [ class "vote-poll-center-outer" ]
        [ div [ class "vote-poll-center" ]
            [ div [ class "submit-row vote-poll-preferred-width" ]
                [ button [ class "submit-button common-button colors-neutral", onClick <| viewConfig.switchBackMessage True ]
                    [ text "Zrušit" ]
                , button [ class "submit-button common-button colors-edit", disabled <| not hasChanges, onClick viewConfig.saveMessage ]
                    [ text "Uložit změny" ]
                ]
            ]
        ]
