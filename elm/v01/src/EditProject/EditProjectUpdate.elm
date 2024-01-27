module EditProject.EditProjectUpdate exposing (init, update)

import Browser.Dom
import Data.DataModel exposing (PollId, Project)
import EditProject.EditProjectModel exposing (ChangesInProjectDefinition, Msg(..), emptyChangesInProjectDefinition)
import PollEditor.PollEditorModel exposing (PollEditorMsg)
import PollEditor.PollEditorUpdate as PollEditorUpdate
import SDate.SDate exposing (SDay)
import Task


init : Project -> SDay -> ChangesInProjectDefinition
init project today =
    emptyChangesInProjectDefinition project today


update : Msg -> Project -> ChangesInProjectDefinition -> (Msg -> m) -> ( ChangesInProjectDefinition, Cmd m )
update msg project changesInProjectDefinition wrap =
    case msg of
        ChangeTitle title ->
            let
                newChangedTitle =
                    if project.title == Just title || (String.isEmpty title && project.title == Nothing) then
                        Nothing

                    else
                        Just title
            in
            ( { changesInProjectDefinition | changedTitle = newChangedTitle }, Cmd.none )

        ChangePoll pollId pollEditorMsg ->
            ( updateModelWithId changesInProjectDefinition pollId pollEditorMsg, Cmd.none )

        ScrollDown ->
            let
                cmd =
                    Browser.Dom.getViewport
                        |> Task.andThen (\info -> Browser.Dom.setViewport 0 info.scene.height)
                        |> Task.attempt (\_ -> wrap NoOp)
            in
            ( changesInProjectDefinition, cmd )

        NoOp ->
            ( changesInProjectDefinition, Cmd.none )


updateModelWithId : ChangesInProjectDefinition -> PollId -> PollEditorMsg -> ChangesInProjectDefinition
updateModelWithId changesInProjectDefinition pollId pollEditorMsg =
    let
        updateItem ( editorPollId, pollEditorModel ) =
            if editorPollId == pollId then
                ( editorPollId, PollEditorUpdate.update pollEditorMsg pollEditorModel )

            else
                ( editorPollId, pollEditorModel )

        updatedModels =
            List.map updateItem changesInProjectDefinition.pollEditorModels
    in
    { changesInProjectDefinition | pollEditorModels = updatedModels }
