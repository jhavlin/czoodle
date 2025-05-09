module PollEditor.PollEditorModel exposing
    ( CandidatesEditor(..)
    , CandidatesEditorMsg(..)
    , PollEditorModel
    , PollEditorMsg(..)
    , VotesEditor(..)
    , VotesEditorMsg(..)
    , isChanged
    )

import Candidate.DateCandidate.DateCandidatesEditorModel as DateCandidatesEditorModel
    exposing
        ( DateCandidatesEditorModel
        , DateCandidatesEditorMsg
        )
import Candidate.TextCandidate.TextCandidatesEditorModel as TextCandidatesEditorModel
    exposing
        ( TextCandidatesEditorModel
        , TextCandidatesEditorMsg
        )
import Maybe exposing (Maybe)


type PollEditorMsg
    = SetPollTitle String
    | SetPollDescription String
    | InnerMsgCandidates CandidatesEditorMsg
    | InnerMsgVotes VotesEditorMsg
    | NoOp


type CandidatesEditorMsg
    = InnerMsgDate DateCandidatesEditorMsg
    | InnerMsgText TextCandidatesEditorMsg


type VotesEditorMsg
    = InnerMsgYesNo


type alias PollEditorModel =
    { originalTitle : String
    , originalDescription : String
    , changedTitle : Maybe String
    , changedDescription : Maybe String
    , candidatesEditor : CandidatesEditor
    , votesEditor : VotesEditor
    }


type CandidatesEditor
    = DateCandidatesEditor DateCandidatesEditorModel
    | TextCandidatesEditor TextCandidatesEditorModel


type VotesEditor
    = YesNoVotesEditor


isJust : Maybe a -> Bool
isJust maybe =
    case maybe of
        Just _ ->
            True

        Nothing ->
            False


isChanged : PollEditorModel -> Bool
isChanged editorModel =
    isJust editorModel.changedTitle
        || isJust editorModel.changedDescription
        || isCandidatesChanged editorModel.candidatesEditor
        || isVotesChanged editorModel.votesEditor


isCandidatesChanged : CandidatesEditor -> Bool
isCandidatesChanged candidatesEditor =
    case candidatesEditor of
        DateCandidatesEditor model ->
            DateCandidatesEditorModel.isChanged model

        TextCandidatesEditor model ->
            TextCandidatesEditorModel.isChanged model


isVotesChanged : VotesEditor -> Bool
isVotesChanged votesEditor =
    case votesEditor of
        YesNoVotesEditor ->
            False
