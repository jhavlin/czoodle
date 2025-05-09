module Candidate.TextCandidate.TextCandidatesEditorUpdate exposing (update)

import Candidate.TextCandidate.TextCandidatesEditorModel
    exposing
        ( TextCandidatesEditorModel
        , TextCandidatesEditorMsg(..)
        )
import Common.ListUtils as ListUtils
import Data.CandidateId exposing (CandidateId, candidateIdInt)
import Dict
import List
import Set



---- Update ----


update : TextCandidatesEditorMsg -> TextCandidatesEditorModel -> TextCandidatesEditorModel
update msg model =
    case msg of
        SetNewGenericPollItem itemNumber itemVal ->
            setNewGenericItem itemNumber itemVal model

        AddGenericPollItem ->
            addGenericItem model

        RemoveGenericPollItem itemNumber ->
            removeGenericItem itemNumber model

        RenameGenericPollItem candidateId value ->
            renameGenericItem candidateId value model

        HideGenericPollItem candidateId ->
            hideGenericItem candidateId model

        UnhideGenericPollItem candidateId ->
            unhideGenericItem candidateId model

        NoOp ->
            model


addGenericItem : TextCandidatesEditorModel -> TextCandidatesEditorModel
addGenericItem data =
    { data | addedItems = data.addedItems ++ [ "" ] }


setNewGenericItem : Int -> String -> TextCandidatesEditorModel -> TextCandidatesEditorModel
setNewGenericItem itemNumber newValue data =
    { data | addedItems = ListUtils.changeIndex (\_ -> newValue) itemNumber data.addedItems }


removeGenericItem : Int -> TextCandidatesEditorModel -> TextCandidatesEditorModel
removeGenericItem itemNumber data =
    let
        newItems =
            if List.length data.addedItems > 1 || not (List.isEmpty data.originalItems) then
                ListUtils.removeIndex itemNumber data.addedItems

            else
                ListUtils.changeIndex (\_ -> "") itemNumber data.addedItems
    in
    { data | addedItems = newItems }


renameGenericItem : CandidateId -> String -> TextCandidatesEditorModel -> TextCandidatesEditorModel
renameGenericItem candidateId value pollData =
    let
        valueOpt =
            ListUtils.findFirst (\i -> i.candidateId == candidateId) pollData.originalItems
                |> Maybe.map .value

        newRenamedItems =
            if Just value == valueOpt then
                Dict.remove (candidateIdInt candidateId) pollData.renamedItems

            else
                Dict.insert (candidateIdInt candidateId) value pollData.renamedItems
    in
    { pollData | renamedItems = newRenamedItems }


hideGenericItem : CandidateId -> TextCandidatesEditorModel -> TextCandidatesEditorModel
hideGenericItem candidateId pollData =
    let
        originallyHidden =
            ListUtils.findFirst (\i -> i.candidateId == candidateId) pollData.originalItems
                |> Maybe.map .hidden
                |> Maybe.withDefault False
    in
    if originallyHidden then
        { pollData | unhiddenItems = Set.remove (candidateIdInt candidateId) pollData.unhiddenItems }

    else
        { pollData | hiddenItems = Set.insert (candidateIdInt candidateId) pollData.hiddenItems }


unhideGenericItem : CandidateId -> TextCandidatesEditorModel -> TextCandidatesEditorModel
unhideGenericItem candidateId pollData =
    let
        originallyHidden =
            ListUtils.findFirst (\i -> i.candidateId == candidateId) pollData.originalItems
                |> Maybe.map .hidden
                |> Maybe.withDefault False
    in
    if originallyHidden then
        { pollData | unhiddenItems = Set.insert (candidateIdInt candidateId) pollData.unhiddenItems }

    else
        { pollData | hiddenItems = Set.remove (candidateIdInt candidateId) pollData.hiddenItems }
