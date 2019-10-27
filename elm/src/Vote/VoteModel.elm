module Vote.VoteModel exposing (Model, Msg(..), ProjectState(..), ViewMode(..), ViewState, ViewStates, actualChanges, applyPersonRowChanges, containsInvalidChange, emptyChangesInPersonRow, emptyChangesInPoll, emptyViewState, isInvalidAddedPersonRow, mergePollWithChanges, mergeWithChanges, pollOptionIds)

import Data.DataModel exposing (..)
import Dict exposing (..)
import Json.Decode as D
import SDate.SDate exposing (SDay)
import Set exposing (..)



------------------------------------------------------------
---- Types -------------------------------------------------
------------------------------------------------------------


type Msg
    = NoOp
    | NoOpJson D.Value
    | LoadedData D.Value
    | HashChanged D.Value
    | MakePersonRowEditable PollId PersonId
    | MakePersonRowNotEditable PollId PersonId
    | SetAddedPersonRowOption PollId Int OptionId SelectedOption
    | SetAddedPersonRowName PollId Int String
    | DeleteAddedPersonRow PollId Int
    | DeleteAllEmptyPersonRows
    | AddAnotherPersonRow PollId
    | SetExistingPersonRowOption PollId PersonId OptionId SelectedOption
    | SetExistingPersonRowName PollId PersonId String
    | DeleteExistingPersonRow PollId PersonId
    | UndeleteExistingPersonRow PollId PersonId
    | SaveChanges
    | RetrySaveChanges D.Value


type ViewMode
    = OptionsInRow
    | PeopleInRow


type alias ViewState =
    { viewMode : ViewMode
    , editableExistingRows : Set Int
    }


type alias ViewStates =
    Dict Int ViewState


type ProjectState
    = Loading
    | Loaded Project ChangesInProject ViewStates
    | Error String
    | Saving Project ChangesInProject ViewStates


type alias Model =
    { keys : Keys
    , projectState : ProjectState
    }



------------------------------------------------------------
---- Functions ---------------------------------------------
------------------------------------------------------------


emptyChangesInPoll : ChangesInPoll
emptyChangesInPoll =
    { changesInPersonRows = Dict.empty, addedPersonRows = [], deletedPersonRows = Set.empty }


emptyViewState : ViewState
emptyViewState =
    { viewMode = OptionsInRow, editableExistingRows = Set.empty }


emptyChangesInPersonRow : ChangesInPersonRow
emptyChangesInPersonRow =
    { changedName = Nothing
    , changedOptions = Dict.empty
    }


applyPersonRowChanges : ChangesInPoll -> PersonRow -> PersonRow
applyPersonRowChanges changesInPoll personRow =
    let
        changesInRow =
            Dict.get (personIdInt personRow.personId) changesInPoll.changesInPersonRows

        updateName changedName =
            case changedName of
                Just newName ->
                    newName

                Nothing ->
                    personRow.name

        updateOptions changedOptions =
            Dict.union changedOptions personRow.selectedOptions
    in
    case changesInRow of
        Just { changedName, changedOptions } ->
            { personRow
                | name = updateName changedName
                , selectedOptions = updateOptions changedOptions
            }

        Nothing ->
            personRow


mergePollWithChanges : Poll -> ChangesInPoll -> Poll
mergePollWithChanges poll changesInPoll =
    let
        appliedPersonChanges =
            List.map (applyPersonRowChanges changesInPoll) poll.personRows

        appliedDeletes =
            List.filter (\pc -> not <| Set.member (personIdInt pc.personId) changesInPoll.deletedPersonRows) appliedPersonChanges

        newPersonRow : Int -> AddedPersonRow -> PersonRow
        newPersonRow i addedPersonRow =
            { personId = PersonId <| poll.lastPersonId + i + 1
            , name = addedPersonRow.name
            , selectedOptions = addedPersonRow.selectedOptions
            }

        nonEmptyAddedRows =
            List.filter (\apr -> not <| String.isEmpty <| String.trim apr.name) changesInPoll.addedPersonRows

        newPersonRows =
            List.indexedMap newPersonRow nonEmptyAddedRows

        updatedPersonRows =
            appliedDeletes ++ newPersonRows
    in
    { poll
        | personRows = updatedPersonRows
        , lastPersonId = poll.lastPersonId + List.length newPersonRows
    }


mergeWithChanges : Project -> ChangesInProject -> Project
mergeWithChanges project changesInProject =
    let
        newComment i addedComment =
            { commentId = CommentId <| project.lastCommentId + i + 1
            , text = addedComment.text
            }

        newComments =
            List.indexedMap newComment changesInProject.addedComments

        updatedComments =
            project.comments ++ newComments

        updatePoll poll =
            let
                changesInPoll =
                    Maybe.withDefault emptyChangesInPoll <|
                        Dict.get (pollIdInt poll.pollId) changesInProject.changesInPolls
            in
            mergePollWithChanges poll changesInPoll

        updatedPolls =
            List.map updatePoll project.polls
    in
    { project
        | polls = updatedPolls
        , comments = updatedComments
        , lastCommentId = project.lastCommentId + List.length changesInProject.addedComments
    }


pollOptionIds : Poll -> List OptionId
pollOptionIds poll =
    case poll.pollInfo of
        DatePollInfo { items } ->
            List.map .optionId items

        GenericPollInfo { items } ->
            List.map .optionId items


isInvalidAddedPersonRow : AddedPersonRow -> Bool
isInvalidAddedPersonRow addedPersonRow =
    let
        hasEmptyName =
            String.isEmpty <| String.trim addedPersonRow.name

        hasPositiveVote =
            not <| Dict.isEmpty <| Dict.filter (\k v -> v /= No) addedPersonRow.selectedOptions
    in
    hasEmptyName && hasPositiveVote


containsInvalidChange : ChangesInProject -> Bool
containsInvalidChange changesInProject =
    let
        checkPoll _ changesInPoll prev =
            prev || List.any isInvalidAddedPersonRow changesInPoll.addedPersonRows
    in
    Dict.foldl checkPoll False changesInProject.changesInPolls


{-| Normalize changes so that thay contain only selected options that differ from persisted project.
-}
actualChanges : ChangesInProject -> Project -> ChangesInProject
actualChanges changesInProject project =
    let
        fixChangesInPoll : Poll -> Dict Int ChangesInPoll -> Dict Int ChangesInPoll
        fixChangesInPoll poll dict =
            let
                changesInPoll =
                    Maybe.withDefault emptyChangesInPoll <| Dict.get (pollIdInt poll.pollId) changesInProject.changesInPolls

                pollIdValid id =
                    List.any (\vi -> vi.personId == PersonId id) poll.personRows

                fixedDeletedVotes =
                    Set.filter pollIdValid changesInPoll.deletedPersonRows

                fixChangedVotes personInfo peopleChangesDict =
                    let
                        perId =
                            personIdInt personInfo.personId

                        changedVotesItem =
                            Maybe.withDefault { changedName = Nothing, changedOptions = Dict.empty } <|
                                Dict.get perId changesInPoll.changesInPersonRows

                        fixedName =
                            if changedVotesItem.changedName == Just personInfo.name || changedVotesItem.changedName == Just "" then
                                Nothing

                            else
                                changedVotesItem.changedName

                        fixOptionSet (OptionId id) optionsDict =
                            let
                                valueInPersisted =
                                    Maybe.withDefault No <| Dict.get id personInfo.selectedOptions

                                valueInChanges =
                                    Maybe.withDefault valueInPersisted <| Dict.get id changedVotesItem.changedOptions
                            in
                            if valueInChanges /= valueInPersisted then
                                Dict.insert id valueInChanges optionsDict

                            else
                                optionsDict

                        fixedChangedOptions =
                            List.foldl fixOptionSet Dict.empty (pollOptionIds poll)
                    in
                    if fixedName == Nothing && Dict.isEmpty fixedChangedOptions then
                        peopleChangesDict

                    else
                        Dict.insert perId { changedName = fixedName, changedOptions = fixedChangedOptions } peopleChangesDict

                fixedChangesVotes =
                    List.foldl fixChangedVotes Dict.empty poll.personRows
            in
            Dict.insert (pollIdInt poll.pollId)
                { addedPersonRows = changesInPoll.addedPersonRows
                , deletedPersonRows = fixedDeletedVotes
                , changesInPersonRows = fixedChangesVotes
                }
                dict
    in
    { changesInPolls = List.foldl fixChangesInPoll Dict.empty project.polls
    , addedComments = changesInProject.addedComments
    }