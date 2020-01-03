port module Vote.VoteUpdate exposing (init, subscriptions, update)

import Browser.Dom
import Common.CommonDecoders exposing (decodeDay)
import Data.DataDecoders exposing (decodeProject)
import Data.DataEncoders exposing (encodeProjectAndKeys)
import Data.DataModel
    exposing
        ( OptionId(..)
        , PersonId(..)
        , PersonRow
        , Poll
        , PollId(..)
        , Project
        , SelectedOption(..)
        , optionIdInt
        , personIdInt
        , pollIdInt
        )
import Dict exposing (Dict)
import EditProject.EditProjectModel exposing (mergeProjectWithDefinitionChanges)
import EditProject.EditProjectUpdate exposing (init, update)
import Json.Decode as D
import Json.Encode as E
import SDate.SDate exposing (defaultDay)
import Set
import Task
import Translations.Translations as Translations
import Translations.TranslationsDecoders exposing (decodeTranslation)
import Vote.VoteModel
    exposing
        ( AddedPersonRow
        , ChangesInPersonRow
        , ChangesInPoll
        , ChangesInProject
        , Model
        , Msg(..)
        , ProjectState(..)
        , ViewMode(..)
        , ViewState
        , ViewStates
        , actualChanges
        , emptyChangesInProject
        , mergeWithChanges
        )


port load : E.Value -> Cmd msg


port modify : E.Value -> Cmd msg


port loaded : (D.Value -> msg) -> Sub msg


port hashChanged : (D.Value -> msg) -> Sub msg


port modified : (D.Value -> msg) -> Sub msg


port updatedVersionReceived : (D.Value -> msg) -> Sub msg



------------------------------------------------------------
---- Init --------------------------------------------------
------------------------------------------------------------


init : D.Value -> ( Model, Cmd Msg )
init jsonFlags =
    let
        urlHashResult =
            D.decodeValue (D.field "urlHash" D.string) jsonFlags

        urlHash =
            Result.withDefault "#0/0" urlHashResult

        hashParts =
            urlHash |> String.dropLeft 1 |> String.split "/"

        projectKey =
            Maybe.withDefault "0" <| List.head hashParts

        secretKey =
            String.join "def" <| Maybe.withDefault [] <| List.tail hashParts

        projectState =
            case urlHashResult of
                Ok _ ->
                    Loading

                Err _ ->
                    Error "Špatný hash"

        command =
            case urlHashResult of
                Ok _ ->
                    load <| E.object [ ( "projectKey", E.string projectKey ), ( "secretKey", E.string secretKey ) ]

                Err _ ->
                    Cmd.none

        todayResult =
            D.decodeValue (D.field "today" decodeDay) jsonFlags

        today =
            Result.withDefault Nothing todayResult |> Maybe.withDefault defaultDay

        translation =
            Result.withDefault Translations.default <| D.decodeValue decodeTranslation jsonFlags
    in
    ( { keys = { projectKey = projectKey, secretKey = secretKey }
      , projectState = projectState
      , today = today
      , translation = translation
      }
    , command
    )


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



------------------------------------------------------------
---- Subscriptins ------------------------------------------
------------------------------------------------------------


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ loaded LoadedData
        , modified NoOpJson
        , updatedVersionReceived RetrySaveChanges
        , hashChanged HashChanged
        ]



------------------------------------------------------------
---- Update ------------------------------------------------
------------------------------------------------------------


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        NoOpJson _ ->
            ( model, Cmd.none )

        LoadedData json ->
            let
                newModel =
                    { model | projectState = loadProject json }

                cmd =
                    case model.projectState of
                        SavingDefinition _ _ ->
                            Browser.Dom.setViewport 0 0
                                |> Task.attempt (\_ -> NoOp)

                        _ ->
                            Cmd.none
            in
            ( newModel, cmd )

        HashChanged hash ->
            init hash

        MakePersonRowEditable pollId (PersonId personId) ->
            let
                doFn poll changesInPoll viewState =
                    let
                        updatedViewState =
                            { viewState | editableExistingRows = Set.insert personId viewState.editableExistingRows }
                    in
                    ( poll, changesInPoll, updatedViewState )
            in
            ( doWithPoll model pollId doFn, Cmd.none )

        MakePersonRowNotEditable pollId (PersonId personId) ->
            let
                doFn poll changesInPoll viewState =
                    let
                        updatedViewState =
                            { viewState | editableExistingRows = Set.remove personId viewState.editableExistingRows }

                        updatedChangesInPoll =
                            { changesInPoll
                                | changesInPersonRows = Dict.remove personId changesInPoll.changesInPersonRows
                                , deletedPersonRows = Set.remove personId changesInPoll.deletedPersonRows
                            }
                    in
                    ( poll, updatedChangesInPoll, updatedViewState )
            in
            ( doWithPoll model pollId doFn, Cmd.none )

        SetAddedPersonRowOption pollId index (OptionId id) selectedOption ->
            let
                fn addedVote =
                    { addedVote | selectedOptions = Dict.insert id selectedOption addedVote.selectedOptions }
            in
            ( doWithAddedVote model pollId index fn, Cmd.none )

        SetAddedPersonRowName pollId index name ->
            let
                doFn project changes viewState =
                    let
                        sourceChanges =
                            Dict.get (pollIdInt pollId) changes.changesInPolls

                        foldFn ( i, addedVote ) str =
                            if index == i then
                                addedVote.name

                            else
                                str

                        findOrigName changesItem =
                            List.foldl foldFn "" <| List.indexedMap Tuple.pair changesItem.addedPersonRows

                        origName =
                            Maybe.withDefault "" <| Maybe.map findOrigName sourceChanges

                        updateName pId i addedVote =
                            if i == index && (addedVote.name == origName || pId == pollId) then
                                { addedVote | name = name }

                            else
                                addedVote

                        updateAddedPersonRows pId addedVotes =
                            List.indexedMap (updateName pId) addedVotes

                        updateChangesInPoll id changesInPoll =
                            { changesInPoll | addedPersonRows = updateAddedPersonRows (PollId id) changesInPoll.addedPersonRows }

                        updatedChanges =
                            Dict.map updateChangesInPoll changes.changesInPolls
                    in
                    Loaded project { changes | changesInPolls = updatedChanges } viewState
            in
            ( doWithLoadedProject model doFn, Cmd.none )

        AddAnotherPersonRow ->
            let
                updateAddedPersonRows addedVotes =
                    addedVotes ++ [ { name = "", selectedOptions = Dict.empty } ]

                doFn changesInPoll =
                    { changesInPoll | addedPersonRows = updateAddedPersonRows changesInPoll.addedPersonRows }
            in
            ( doWithEachPollChanges model doFn, Cmd.none )

        DeleteAddedPersonRow pollId addedVoteIndex ->
            let
                doFn poll changesInPoll viewState =
                    let
                        foldFn ( index, addedVote ) previousVotes =
                            if addedVoteIndex == index then
                                previousVotes

                            else
                                addedVote :: previousVotes

                        removeAddedVote votes =
                            List.foldr foldFn [] <| List.indexedMap Tuple.pair votes

                        updatedChangesItem =
                            { changesInPoll | addedPersonRows = removeAddedVote changesInPoll.addedPersonRows }
                    in
                    ( poll, updatedChangesItem, viewState )
            in
            ( doWithPoll model pollId doFn, Cmd.none )

        DeleteAllEmptyPersonRows ->
            let
                updateAddedPersonRows addedVotes =
                    List.filter (\av -> not <| String.isEmpty av.name) addedVotes

                doFn changesInPoll =
                    { changesInPoll | addedPersonRows = updateAddedPersonRows changesInPoll.addedPersonRows }
            in
            ( doWithEachPollChanges model doFn, Cmd.none )

        SaveChanges ->
            case model.projectState of
                Loaded project changesInProject viewStates ->
                    let
                        actChanges =
                            actualChanges changesInProject project

                        merged =
                            mergeWithChanges project actChanges

                        encoded =
                            encodeProjectAndKeys merged model.keys
                    in
                    ( { model | projectState = Saving project changesInProject viewStates }, modify encoded )

                _ ->
                    ( model, Cmd.none )

        SetExistingPersonRowOption pollId personId optionId selectedOption ->
            let
                doFn : PersonRow -> ChangesInPersonRow -> ChangesInPersonRow
                doFn personRow changesInPersonRow =
                    let
                        orig =
                            Maybe.withDefault No <| Dict.get (optionIdInt optionId) personRow.selectedOptions

                        updatedOptions =
                            if orig == selectedOption then
                                Dict.remove (optionIdInt optionId) changesInPersonRow.changedOptions

                            else
                                Dict.insert (optionIdInt optionId) selectedOption changesInPersonRow.changedOptions
                    in
                    { changesInPersonRow | changedOptions = updatedOptions }
            in
            ( doWithExistingVote model pollId personId doFn, Cmd.none )

        SetExistingPersonRowName pollId personId newName ->
            let
                doFn : PersonRow -> ChangesInPersonRow -> ChangesInPersonRow
                doFn personRow changesInPersonRow =
                    if newName == personRow.name then
                        { changesInPersonRow | changedName = Nothing }

                    else
                        { changesInPersonRow | changedName = Just newName }
            in
            ( doWithExistingVote model pollId personId doFn, Cmd.none )

        DeleteExistingPersonRow pollId personId ->
            let
                doFn poll changesInPoll viewState =
                    let
                        updatedChanges =
                            { changesInPoll
                                | deletedPersonRows = Set.insert (personIdInt personId) changesInPoll.deletedPersonRows
                            }
                    in
                    ( poll, updatedChanges, viewState )
            in
            ( doWithPoll model pollId doFn, Cmd.none )

        UndeleteExistingPersonRow pollId personId ->
            let
                doFn poll changesInPoll viewState =
                    let
                        updatedChanges =
                            { changesInPoll
                                | deletedPersonRows = Set.remove (personIdInt personId) changesInPoll.deletedPersonRows
                            }
                    in
                    ( poll, updatedChanges, viewState )
            in
            ( doWithPoll model pollId doFn, Cmd.none )

        RetrySaveChanges json ->
            let
                loadResult =
                    loadProject json
            in
            case model.projectState of
                Saving _ origChanges _ ->
                    case loadResult of
                        Loaded project _ _ ->
                            let
                                actChanges =
                                    actualChanges origChanges project

                                merged =
                                    mergeWithChanges project actChanges

                                encoded =
                                    encodeProjectAndKeys merged model.keys
                            in
                            ( model, modify encoded )

                        _ ->
                            ( model, Cmd.none )

                SavingDefinition _ changesInProjectDefinition ->
                    case loadResult of
                        Loaded project _ _ ->
                            let
                                merged =
                                    mergeProjectWithDefinitionChanges project changesInProjectDefinition

                                encoded =
                                    encodeProjectAndKeys merged model.keys
                            in
                            ( model, modify encoded )

                        _ ->
                            ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        SwitchToDefinitionEditor ->
            case model.projectState of
                Loaded project _ _ ->
                    ( { model | projectState = Editing project (EditProject.EditProjectUpdate.init project model.today) }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        SwitchToVotesEditor scroll ->
            let
                cmd =
                    if scroll then
                        Browser.Dom.setViewport 0 0
                            |> Task.attempt (\_ -> NoOp)

                    else
                        Cmd.none
            in
            case model.projectState of
                Editing project _ ->
                    ( { model | projectState = Loaded project (emptyChangesInProject project) Dict.empty }, cmd )

                _ ->
                    ( model, Cmd.none )

        SaveProjectDefinitionChanges ->
            case model.projectState of
                Editing project changesInProjectDefinition ->
                    let
                        merged =
                            mergeProjectWithDefinitionChanges project changesInProjectDefinition

                        encoded =
                            encodeProjectAndKeys merged model.keys
                    in
                    ( { model | projectState = SavingDefinition project changesInProjectDefinition }, modify encoded )

                _ ->
                    ( model, Cmd.none )

        EditProjectMsg editProjectMsg ->
            case model.projectState of
                Editing project changesInProjectDefinition ->
                    let
                        ( updatedProjectState, cmd ) =
                            EditProject.EditProjectUpdate.update editProjectMsg project changesInProjectDefinition EditProjectMsg
                    in
                    ( { model | projectState = Editing project updatedProjectState }, cmd )

                _ ->
                    ( model, Cmd.none )

        SetTranslation code ->
            ( { model | translation = Translations.get code }, Cmd.none )


doWithLoadedProject : Model -> (Project -> ChangesInProject -> ViewStates -> ProjectState) -> Model
doWithLoadedProject model fn =
    case model.projectState of
        Loaded project changesInPoll viewStates ->
            { model | projectState = fn project changesInPoll viewStates }

        _ ->
            model


doWithPoll : Model -> PollId -> (Poll -> ChangesInPoll -> ViewState -> ( Poll, ChangesInPoll, ViewState )) -> Model
doWithPoll model pollId fn =
    let
        updatePoll : Poll -> List Poll -> ChangesInProject -> ViewStates -> ( List Poll, ChangesInProject, ViewStates )
        updatePoll actualPoll previousPolls changesInProject viewStates =
            let
                pId =
                    pollIdInt actualPoll.pollId

                changesItem =
                    Maybe.withDefault emptyChangesInPoll <| Dict.get pId changesInProject.changesInPolls

                viewState =
                    Maybe.withDefault emptyViewState <| Dict.get pId viewStates

                ( updatedPoll, updatedChangesItem, updatedViewState ) =
                    fn actualPoll changesItem viewState
            in
            ( updatedPoll :: previousPolls
            , { changesInProject | changesInPolls = Dict.insert pId updatedChangesItem changesInProject.changesInPolls }
            , Dict.insert pId updatedViewState viewStates
            )

        doFn : Project -> ChangesInProject -> ViewStates -> ProjectState
        doFn project changesInProject viewStates =
            let
                foldInitial =
                    ( [], changesInProject, viewStates )

                foldFn currentPoll ( previousPolls, previousChanges, previousViewStates ) =
                    if currentPoll.pollId == pollId then
                        updatePoll currentPoll previousPolls previousChanges previousViewStates

                    else
                        ( currentPoll :: previousPolls, previousChanges, previousViewStates )

                ( updatedPolls, updatedChangesInProject, updatedViewStates ) =
                    List.foldr foldFn foldInitial project.polls

                updatedProject =
                    { project | polls = updatedPolls }
            in
            Loaded updatedProject updatedChangesInProject updatedViewStates
    in
    doWithLoadedProject model doFn


doWithExistingVote : Model -> PollId -> PersonId -> (PersonRow -> ChangesInPersonRow -> ChangesInPersonRow) -> Model
doWithExistingVote model pollId personId fn =
    let
        doFn poll changesInPoll viewState =
            let
                changesForPerson : ChangesInPersonRow
                changesForPerson =
                    Maybe.withDefault emptyChangesInPersonRow <| Dict.get (personIdInt personId) changesInPoll.changesInPersonRows

                updateChanges : PersonRow -> Dict Int ChangesInPersonRow -> Dict Int ChangesInPersonRow
                updateChanges personRow changesInPersonRows =
                    if personRow.personId == personId then
                        Dict.insert (personIdInt personId) (fn personRow changesForPerson) changesInPersonRows

                    else
                        changesInPersonRows

                updatedPersonRows =
                    List.foldl updateChanges changesInPoll.changesInPersonRows poll.personRows

                updatedChanges =
                    { changesInPoll | changesInPersonRows = updatedPersonRows }
            in
            ( poll, updatedChanges, viewState )
    in
    doWithPoll model pollId doFn


doWithAddedVote : Model -> PollId -> Int -> (AddedPersonRow -> AddedPersonRow) -> Model
doWithAddedVote model pollId addedVoteIndex fn =
    let
        mapFn index addedVote =
            if index == addedVoteIndex then
                fn addedVote

            else
                addedVote

        doFn poll changesItem viewState =
            let
                updatedChangesItem =
                    { changesItem | addedPersonRows = List.indexedMap mapFn changesItem.addedPersonRows }
            in
            ( poll, updatedChangesItem, viewState )
    in
    doWithPoll model pollId doFn


doWithEachPollChanges : Model -> (ChangesInPoll -> ChangesInPoll) -> Model
doWithEachPollChanges model fn =
    let
        doFn project changes viewState =
            let
                updatedChanges =
                    Dict.map (\_ b -> fn b) changes.changesInPolls
            in
            Loaded project { changes | changesInPolls = updatedChanges } viewState
    in
    doWithLoadedProject model doFn


loadProject : D.Value -> ProjectState
loadProject json =
    let
        decodeResult =
            decodeProject json
    in
    case decodeResult of
        Ok r ->
            Loaded r (emptyChangesInProject r) Dict.empty

        Err e ->
            Error (D.errorToString e)
