module EditProject.EditProjectModel exposing
    ( ChangesInProjectDefinition
    , Msg(..)
    , emptyChangesInProjectDefinition
    , mergeProjectWithDefinitionChanges
    )

import Candidate.DateCandidate.DateCandidateData exposing (DateCandidateItem)
import Candidate.DateCandidate.DateCandidatesEditorModel exposing (DateCandidatesEditorData)
import Candidate.DateCandidate.SDate exposing (SDay, dayFromTuple, dayToTuple, defaultDay, monthFromDay)
import Candidate.TextCandidate.TextCandidateData exposing (TextCandidateItem)
import Candidate.TextCandidate.TextCandidatesEditorModel exposing (TextCandidatesEditorModel)
import Common.CommonModel exposing (DayTuple)
import Common.CommonUtils exposing (normalizeStringMaybe)
import Data.CandidateId exposing (CandidateId(..), candidateIdInt)
import Data.DataModel
    exposing
        ( CandidatesInfo(..)
        , Poll
        , PollId
        , Project
        , VotesInfo(..)
        )
import Dict
import PollEditor.PollEditorModel
    exposing
        ( CandidatesEditor(..)
        , PollEditorModel
        , PollEditorMsg
        , VotesEditor(..)
        )
import Set exposing (Set)


type Msg
    = ChangeTitle String
    | ChangePoll PollId PollEditorMsg
    | ScrollDown
    | NoOp


type alias ChangesInProjectDefinition =
    { changedTitle : Maybe String
    , pollEditorModels : List ( PollId, PollEditorModel )
    }


emptyChangesInProjectDefinition : Project -> SDay -> ChangesInProjectDefinition
emptyChangesInProjectDefinition project today =
    let
        lastDayInDatePoll : List DateCandidateItem -> SDay
        lastDayInDatePoll dateOptionItems =
            List.filter (\item -> not item.hidden) dateOptionItems
                |> List.head
                |> Maybe.map (\item -> item.value)
                |> Maybe.withDefault defaultDay

        state lastDay =
            { month = monthFromDay lastDay, highlightedDay = Nothing, today = today }

        candidatesInfoToCandidatesEditor : CandidatesInfo -> CandidatesEditor
        candidatesInfoToCandidatesEditor candidatesInfo =
            case candidatesInfo of
                DateCandidatesInfo items ->
                    DateCandidatesEditor
                        { data =
                            { originalItems = items
                            , addedItems = Set.empty
                            , hiddenItems = Set.empty
                            , unhiddenItems = Set.empty
                            }
                        , state = state <| lastDayInDatePoll items
                        }

                TextCandidatesInfo items ->
                    TextCandidatesEditor
                        { originalItems = items
                        , addedItems = []
                        , hiddenItems = Set.empty
                        , unhiddenItems = Set.empty
                        , renamedItems = Dict.empty
                        }

        votesInfoToVotesEditor : VotesInfo -> VotesEditor
        votesInfoToVotesEditor votesInfo =
            case votesInfo of
                YesNoVotesInfo _ ->
                    YesNoVotesEditor

        pollToEditor : Poll -> ( PollId, PollEditorModel )
        pollToEditor poll =
            ( poll.pollId
            , { originalTitle = Maybe.withDefault "" poll.title
              , originalDescription = Maybe.withDefault "" poll.description
              , changedTitle = Nothing
              , changedDescription = Nothing
              , candidatesEditor = candidatesInfoToCandidatesEditor poll.pollInfo.candidatesInfo
              , votesEditor = votesInfoToVotesEditor poll.pollInfo.votesInfo
              }
            )

        editors =
            List.map pollToEditor project.polls
    in
    { changedTitle = Nothing
    , pollEditorModels = editors
    }


mergeDateCandidatesWithChanges : List DateCandidateItem -> DateCandidatesEditorData -> List DateCandidateItem
mergeDateCandidatesWithChanges items editorData =
    let
        originalDays : Set DayTuple
        originalDays =
            Set.fromList <| List.map (\i -> dayToTuple i.value) editorData.originalItems

        addedDays : List SDay
        addedDays =
            Set.toList editorData.addedItems
                |> List.filterMap dayFromTuple
                |> List.filter (\sDay -> not <| Set.member (dayToTuple sDay) originalDays)

        updateItem : DateCandidateItem -> DateCandidateItem
        updateItem item =
            { item
                | hidden =
                    (item.hidden
                        && not (Set.member (candidateIdInt item.candidateId) editorData.unhiddenItems)
                        && not (Set.member (dayToTuple item.value) editorData.addedItems)
                    )
                        || Set.member (candidateIdInt item.candidateId) editorData.hiddenItems
            }

        updatedItems =
            List.map updateItem items

        lastItemId =
            Maybe.withDefault 0 <| List.maximum <| List.map (\i -> candidateIdInt i.candidateId) items

        addedDayToItem : Int -> SDay -> DateCandidateItem
        addedDayToItem index sDay =
            { candidateId = CandidateId <| lastItemId + index + 1
            , value = sDay
            , hidden = False
            }

        newItems =
            List.indexedMap addedDayToItem addedDays
    in
    List.sortBy (\i -> dayToTuple i.value) <| updatedItems ++ newItems


mergeTextCandidatesWithChanges : List TextCandidateItem -> TextCandidatesEditorModel -> List TextCandidateItem
mergeTextCandidatesWithChanges items editorData =
    let
        updateItem : TextCandidateItem -> TextCandidateItem
        updateItem item =
            { item
                | hidden =
                    (item.hidden
                        && not (Set.member (candidateIdInt item.candidateId) editorData.unhiddenItems)
                    )
                        || Set.member (candidateIdInt item.candidateId) editorData.hiddenItems
                , value = Maybe.withDefault item.value <| Dict.get (candidateIdInt item.candidateId) editorData.renamedItems
            }

        updatedItems =
            List.map updateItem items

        lastItemId =
            Maybe.withDefault 0 <| List.maximum <| List.map (\i -> candidateIdInt i.candidateId) items

        stringToItem : Int -> String -> TextCandidateItem
        stringToItem index value =
            { candidateId = CandidateId <| lastItemId + index + 1
            , value = value
            , hidden = False
            }

        newItems : List TextCandidateItem
        newItems =
            List.indexedMap stringToItem editorData.addedItems
    in
    updatedItems ++ newItems


mergePollWithDefinitionChanges : Poll -> ( PollId, PollEditorModel ) -> Poll
mergePollWithDefinitionChanges poll ( pollId, editorModel ) =
    let
        updatedPollTitle =
            case editorModel.changedTitle of
                Nothing ->
                    poll.title

                x ->
                    Maybe.map String.trim x |> normalizeStringMaybe

        updatedPollDescription =
            case editorModel.changedDescription of
                Nothing ->
                    poll.description

                x ->
                    Maybe.map String.trim x |> normalizeStringMaybe

        updatedCandidatesInfo =
            case ( poll.pollInfo.candidatesInfo, editorModel.candidatesEditor ) of
                ( DateCandidatesInfo items, DateCandidatesEditor dateCandidatesEditorModel ) ->
                    DateCandidatesInfo (mergeDateCandidatesWithChanges items dateCandidatesEditorModel.data)

                ( TextCandidatesInfo items, TextCandidatesEditor textCandidatesEditorModel ) ->
                    TextCandidatesInfo (mergeTextCandidatesWithChanges items textCandidatesEditorModel)

                _ ->
                    poll.pollInfo.candidatesInfo
    in
    if pollId == poll.pollId then
        -- panaroic check for future support for reordering
        { poll
            | title = updatedPollTitle
            , description = updatedPollDescription
            , pollInfo =
                { candidatesInfo = updatedCandidatesInfo
                , votesInfo = poll.pollInfo.votesInfo
                }
        }

    else
        poll


mergeProjectWithDefinitionChanges : Project -> ChangesInProjectDefinition -> Project
mergeProjectWithDefinitionChanges project changes =
    let
        updatedTitle =
            case changes.changedTitle of
                Nothing ->
                    project.title

                x ->
                    Maybe.map String.trim x |> normalizeStringMaybe

        updatedPolls =
            List.map2 mergePollWithDefinitionChanges project.polls changes.pollEditorModels
    in
    { project
        | title = updatedTitle
        , polls = updatedPolls
    }
