module EditProject.EditProjectModel exposing
    ( ChangesInProjectDefinition
    , Msg(..)
    , emptyChangesInProjectDefinition
    , mergeProjectWithDefinitionChanges
    )

import Common.CommonModel exposing (DayTuple)
import Common.CommonUtils exposing (normalizeStringMaybe)
import Data.DataModel
    exposing
        ( DateOptionItem
        , GenericOptionItem
        , OptionId(..)
        , Poll
        , PollId
        , PollInfo(..)
        , Project
        , optionIdInt
        )
import Dict
import PollEditor.PollEditorModel
    exposing
        ( DatePollEditorData
        , GenericPollEditorData
        , PollEditor(..)
        , PollEditorModel
        , PollEditorMsg
        )
import SDate.SDate exposing (SDay, dayFromTuple, dayToTuple, defaultDay, monthFromDay)
import Set exposing (Set)


type Msg
    = ChangeTitle String
    | ChangePoll PollId PollEditorMsg


type alias ChangesInProjectDefinition =
    { changedTitle : Maybe String
    , pollEditorModels : List ( PollId, PollEditorModel )
    }


emptyChangesInProjectDefinition : Project -> SDay -> ChangesInProjectDefinition
emptyChangesInProjectDefinition project today =
    let
        lastDayInDatePoll : List DateOptionItem -> SDay
        lastDayInDatePoll dateOptionItems =
            List.filter (\item -> not item.hidden) dateOptionItems
                |> List.head
                |> Maybe.map (\item -> item.value)
                |> Maybe.withDefault defaultDay

        state lastDay =
            { month = monthFromDay lastDay, highlightedDay = Nothing, today = today }

        pollInfoToPollEditor pollInfo =
            case pollInfo of
                DatePollInfo { items } ->
                    DatePollEditor (state <| lastDayInDatePoll items)
                        { originalItems = items
                        , addedItems = Set.empty
                        , hiddenItems = Set.empty
                        , unhiddenItems = Set.empty
                        }

                GenericPollInfo { items } ->
                    GenericPollEditor
                        { originalItems = items
                        , addedItems = []
                        , hiddenItems = Set.empty
                        , unhiddenItems = Set.empty
                        , renamedItems = Dict.empty
                        }

        pollToEditor poll =
            ( poll.pollId
            , { originalTitle = Maybe.withDefault "" poll.title
              , originalDescription = Maybe.withDefault "" poll.description
              , changedTitle = Nothing
              , changedDescription = Nothing
              , editor = pollInfoToPollEditor poll.pollInfo
              }
            )

        editors =
            List.map pollToEditor project.polls
    in
    { changedTitle = Nothing
    , pollEditorModels = editors
    }


mergeDatePollItemsWithChanges : List DateOptionItem -> DatePollEditorData -> List DateOptionItem
mergeDatePollItemsWithChanges items editorData =
    let
        originalDays : Set DayTuple
        originalDays =
            Set.fromList <| List.map (\i -> dayToTuple i.value) editorData.originalItems

        addedDays : List SDay
        addedDays =
            Set.toList editorData.addedItems
                |> List.filterMap dayFromTuple
                |> List.filter (\sDay -> not <| Set.member (dayToTuple sDay) originalDays)

        updateItem : DateOptionItem -> DateOptionItem
        updateItem item =
            { item
                | hidden =
                    (item.hidden
                        && not (Set.member (optionIdInt item.optionId) editorData.unhiddenItems)
                        && not (Set.member (dayToTuple item.value) editorData.addedItems)
                    )
                        || Set.member (optionIdInt item.optionId) editorData.hiddenItems
            }

        updatedItems =
            List.map updateItem items

        lastItemId =
            Maybe.withDefault 0 <| List.maximum <| List.map (\i -> optionIdInt i.optionId) items

        addedDayToItem : Int -> SDay -> DateOptionItem
        addedDayToItem index sDay =
            { optionId = OptionId <| lastItemId + index + 1
            , value = sDay
            , hidden = False
            }

        newItems =
            List.indexedMap addedDayToItem addedDays
    in
    List.sortBy (\i -> dayToTuple i.value) <| updatedItems ++ newItems


mergeGenericPollItemsWithChanges : List GenericOptionItem -> GenericPollEditorData -> List GenericOptionItem
mergeGenericPollItemsWithChanges items editorData =
    let
        updateItem : GenericOptionItem -> GenericOptionItem
        updateItem item =
            { item
                | hidden =
                    (item.hidden
                        && not (Set.member (optionIdInt item.optionId) editorData.unhiddenItems)
                    )
                        || Set.member (optionIdInt item.optionId) editorData.hiddenItems
                , value = Maybe.withDefault item.value <| Dict.get (optionIdInt item.optionId) editorData.renamedItems
            }

        updatedItems =
            List.map updateItem items

        lastItemId =
            Maybe.withDefault 0 <| List.maximum <| List.map (\i -> optionIdInt i.optionId) items

        stringToItem : Int -> String -> GenericOptionItem
        stringToItem index value =
            { optionId = OptionId <| lastItemId + index + 1
            , value = value
            , hidden = False
            }

        newItems : List GenericOptionItem
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

        updatedPollInfo =
            case ( poll.pollInfo, editorModel.editor ) of
                ( DatePollInfo { items }, DatePollEditor _ datePollEditorData ) ->
                    DatePollInfo { items = mergeDatePollItemsWithChanges items datePollEditorData }

                ( GenericPollInfo { items }, GenericPollEditor genericPollEditorData ) ->
                    GenericPollInfo { items = mergeGenericPollItemsWithChanges items genericPollEditorData }

                _ ->
                    poll.pollInfo
    in
    if pollId == poll.pollId then
        -- panaroic check for future support for reordering
        { poll
            | title = updatedPollTitle
            , description = updatedPollDescription
            , pollInfo = updatedPollInfo
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
