module EditProject.EditProjectUpdate exposing (init, update)

import Data.DataModel exposing (PollId, Project)
import EditProject.EditProjectModel exposing (ChangesInProjectDefinition, Msg(..), emptyChangesInProjectDefinition)
import PollEditor.PollEditorModel exposing (PollEditorMsg)
import PollEditor.PollEditorUpdate as PollEditorUpdate
import SDate.SDate exposing (SDay)


init : Project -> SDay -> ChangesInProjectDefinition
init project today =
    emptyChangesInProjectDefinition project today


update : Msg -> Project -> ChangesInProjectDefinition -> ChangesInProjectDefinition
update msg project changesInProjectDefinition =
    case msg of
        ChangeTitle title ->
            let
                newChangedTitle =
                    if project.title == Just title || (String.isEmpty title && project.title == Nothing) then
                        Nothing

                    else
                        Just title
            in
            { changesInProjectDefinition | changedTitle = newChangedTitle }

        ChangePoll pollId pollEditorMsg ->
            updateModelWithId changesInProjectDefinition pollId pollEditorMsg


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
