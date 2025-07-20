module Vote.VoteView exposing (view)

import Common.Header exposing (headerLogo)
import Data.DataModel exposing (Project, PollId(..), Poll, PollInfo)
import Html exposing (Html, div, header, text, h1, h2, table, th, td, a)
import Html.Events exposing (onClick)
import Html.Attributes exposing (attribute, class, title)
import Translations.Translation exposing (Translation)
import Translations.TranslationsView exposing (translationsView)
import Vote.VoteModel exposing (ChangesInProject(..), Model, ProjectState(..), ViewStates)
import Vote.VoteUpdate exposing (Msg(..))
import Dict
import Vote.VoteModel exposing (emptyViewState)
import Common.CommonView exposing (invisibleToClass)


{- Helper type for passing state and pre-computed info between functions -}


type alias ViewModel =
    { project : Project
    , changesInProject : ChangesInProject
    , viewStates : ViewStates

    --, isValidVotingState : Bool TODO
    , hasChangesInVotes : Bool
    , translation : Translation
    }


view : Model -> Html Msg
view model =
    let
        content =
            viewMainContent model
    in
    div
        [ attribute "translate" "no", class "notranslate" ]
        [ header [] [ headerLogo ]
        , div [ class "project" ] [ div [ class "width" ] [ content ] ]
        ]


viewMainContent : Model -> Html Msg
viewMainContent model =
    let
        viewModel project changesInProject viewStates translation =
            { project = project
            , changesInProject = changesInProject
            , viewStates = viewStates
            , translation = translation
            -- TODO
            , hasChangesInVotes = False
            }
    in
    case model.projectState of
        Loaded project changes states ->
            div []
                [ viewTranslate model
                , viewProject <| viewModel project changes states model.translation
                ]

        _ ->
            div [] [ text "TODO" ]


viewTranslate : Model -> Html Msg
viewTranslate model =
    div [ class "vote-poll-center-outer" ]
        [ div [ class "vote-poll-preferred-width relative" ]
            [ translationsView model.translation SetTranslation ]
        ]

viewProject : ViewModel -> Html Msg
viewProject viewModel =
    let

        { project, hasChangesInVotes } = viewModel

        stateForPoll (PollId id) =
            Maybe.withDefault emptyViewState <| Dict.get id viewModel.viewStates

    in
    div [ class "vote-project" ]
        [ div [ class "vote-poll-center-outer" ]
            [ div [ class "vote-poll-center" ]
                [ div [ class "vote-poll-preferred-width vote-project-title-line" ]
                    [ div [ class "vote-project-title-cell" ]
                        [ h1 [ class "vote-project-title" ] [ text <| Maybe.withDefault viewModel.translation.common.untitled project.title ]
                        ]
                    , div [ class ("vote-project-edit-cell" ++ invisibleToClass hasChangesInVotes) ]
                        [ a
                            [ class "vote-project-edit-button"
                            , title viewModel.translation.vote.editProjectTitle
                            , onClick SwitchToDefinitionEditor
                            ]
                            [ text "✎" ]
                        ]
                    ]
                -- TODO , legend viewModel.translation
                ]
            ]
        , div [ class "vote-polls" ] (List.indexedMap (viewPoll viewModel) project.polls)
        -- TODO , viewSubmitRow viewModel
        ]



viewPoll : ViewModel ->  Int -> Poll -> Html Msg
viewPoll viewModel pollIndex poll =
    let
        { project, changesInProject, translation } = viewModel

    in
    div [ class "vote-poll" ]
        [ div [ class "vote-poll-center-outer" ]
            [ div [ class "vote-poll-center" ]
                [ h2 [ class "vote-poll-title vote-poll-preferred-width" ] [ text <| Maybe.withDefault (String.concat [ translation.vote.poll, " ", String.fromInt <| pollIndex + 1 ]) poll.title ]
                , div [ class "vote-poll-description vote-poll-preferred-width" ] [ text <| Maybe.withDefault "" poll.description ]
                ]
            ]
        -- , div [ class "vote-poll-center-outer" ]
        --     [ div [ class "vote-poll-center" ]
        --         [ div [ class "vote-poll-preferred-width" ] []
        --         , table [ class <| "vote-poll-table" ++ marginClass ]
        --             ([ headerRow, resultsRow ] ++ (List.reverse <| existingRows ++ addedVotesRows))
        --         ]
        --     ]
        ]
