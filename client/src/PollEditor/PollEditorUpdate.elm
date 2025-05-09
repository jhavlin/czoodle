module PollEditor.PollEditorUpdate exposing (update)

import Candidate.DateCandidate.DateCandidatesEditorUpdate as DateCandidatesEditorUpdate
import Candidate.TextCandidate.TextCandidatesEditorUpdate as TextCandidatesEditorUpdate
import PollEditor.PollEditorModel
    exposing
        ( CandidatesEditor(..)
        , CandidatesEditorMsg(..)
        , PollEditorModel
        , PollEditorMsg(..)
        , VotesEditor(..)
        )



---- Update ----


update : PollEditorMsg -> PollEditorModel -> PollEditorModel
update msg model =
    case msg of
        SetPollTitle title ->
            setPollTitle title model

        SetPollDescription description ->
            setPollDescription description model

        InnerMsgCandidates innerMsg ->
            handleCandidatesEditorMsg innerMsg model

        {- TODO -}
        InnerMsgVotes _ ->
            model

        NoOp ->
            model


setPollTitle : String -> PollEditorModel -> PollEditorModel
setPollTitle newTitle model =
    let
        newChangedTitle =
            if newTitle == model.originalTitle then
                Nothing

            else
                Just newTitle
    in
    { model | changedTitle = newChangedTitle }


setPollDescription : String -> PollEditorModel -> PollEditorModel
setPollDescription newDescription model =
    let
        newChangedDescription =
            if newDescription == model.originalDescription then
                Nothing

            else
                Just newDescription
    in
    { model | changedDescription = newChangedDescription }


handleCandidatesEditorMsg : CandidatesEditorMsg -> PollEditorModel -> PollEditorModel
handleCandidatesEditorMsg innerMsg model =
    case ( innerMsg, model.candidatesEditor ) of
        ( InnerMsgDate iMsg, DateCandidatesEditor iModel ) ->
            let
                newInnerModel =
                    DateCandidatesEditorUpdate.update iMsg iModel
            in
            { model | candidatesEditor = DateCandidatesEditor newInnerModel }

        ( InnerMsgText iMsg, TextCandidatesEditor iModel ) ->
            let
                newInnerModel =
                    TextCandidatesEditorUpdate.update iMsg iModel
            in
            { model | candidatesEditor = TextCandidatesEditor newInnerModel }

        _ ->
            model
