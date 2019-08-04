port module Vote exposing (Model, Msg(..), init, main, subscriptions, update, view)

import Browser
import Decoders exposing (decodeCreateFlags, decodeDay)
import Dict exposing (..)
import Encoders exposing (encodeDayTuple)
import Html exposing (Html, a, b, br, button, div, h1, h2, input, label, li, ol, option, p, select, span, table, td, text, th, tr)
import Html.Attributes exposing (class, colspan, disabled, href, min, placeholder, selected, tabindex, title, type_, value)
import Html.Events exposing (on, onClick, onInput, onMouseEnter, onMouseLeave)
import Json.Decode as D
import Json.Encode as E
import ListUtils exposing (removeIndex)
import SDate.SDate exposing (..)
import Set exposing (..)
import Svg exposing (circle, line, svg)
import Svg.Attributes as SAttr


port load : E.Value -> Cmd msg


port modify : E.Value -> Cmd msg


port loaded : (D.Value -> msg) -> Sub msg


port modified : (D.Value -> msg) -> Sub msg


port updatedVersionReceived : (D.Value -> msg) -> Sub msg



------------------------------------------------------------
---- Types -------------------------------------------------
------------------------------------------------------------


type alias Keys =
    { projectKey : String
    , secretKey : String
    }


type ViewMode
    = OptionsInRow
    | PeopleInRow


type alias ViewState =
    { viewMode : ViewMode
    }


type alias ViewStates =
    Dict Int ViewState


type SelectedOption
    = Yes
    | No
    | IfNeeded


type PollId
    = PollId Int


type PersonId
    = PersonId Int


type OptionId
    = OptionId Int


type alias DateOptionItem =
    { optionId : OptionId
    , value : SDay
    }


type alias GenericOptionItem =
    { optionId : OptionId
    , value : String
    }


type CommentId
    = CommentId Int


type alias Comment =
    { commentId : CommentId
    , text : String
    }


type alias PersonRow =
    { personId : PersonId
    , name : String
    , selectedOptions : Dict Int SelectedOption
    }


type PollInfo
    = DatePollInfo { items : List DateOptionItem }
    | GenericPollInfo { items : List GenericOptionItem }


type alias Poll =
    { pollId : PollId
    , title : Maybe String
    , pollInfo : PollInfo
    , personRows : List PersonRow
    , lastPersonId : Int
    }


type alias Project =
    { title : Maybe String
    , polls : List Poll
    , lastPollId : Int
    , comments : List Comment
    , lastCommentId : Int
    , evidence : String
    }


type alias ChangesInProject =
    { changesInPolls : Dict Int ChangesInPoll
    , addedComments : List AddedComment
    }


type alias AddedComment =
    { text : String
    }


type alias ChangesInPoll =
    { changesInPersonRows : Dict Int ChangesInPersonRow
    , addedPersonRows : List AddedPersonRow
    , deletedPersonRows : Set Int
    }


type alias ChangesInPersonRow =
    { changedName : Maybe String
    , changedOptions : Dict Int SelectedOption
    }


type alias AddedPersonRow =
    { name : String
    , selectedOptions : Dict Int SelectedOption
    }


type ProjectState
    = Loading
    | Loaded Project ChangesInProject ViewStates
    | Error String
    | Saving Project ChangesInProject ViewStates


type Msg
    = NoOp
    | NoOpJson D.Value
    | LoadedData D.Value
    | SetAddedPersonRowOption PollId Int OptionId SelectedOption
    | SetAddedPersonRowName PollId Int String
    | DeleteAddedPersonRow PollId Int
    | AddAnotherPersonRow PollId
    | SetExistingPersonRowOption PollId PersonId OptionId SelectedOption
    | SetExistingPersonRowName PollId PersonId String
    | DeleteExistingPersonRow PollId PersonId
    | UndeleteExistingPersonRow PollId PersonId
    | SaveChanges
    | RetrySaveChanges D.Value


type alias Model =
    { keys : Keys
    , projectState : ProjectState
    }



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
    in
    ( { keys = { projectKey = projectKey, secretKey = secretKey }
      , projectState = projectState
      }
    , command
    )


emptyChangesInPoll : ChangesInPoll
emptyChangesInPoll =
    { changesInPersonRows = Dict.empty, addedPersonRows = [], deletedPersonRows = Set.empty }


emptyViewState : ViewState
emptyViewState =
    { viewMode = OptionsInRow }


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
            in
            ( newModel, Cmd.none )

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
                        fromFirst =
                            isFirstPoll pollId project.polls

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
                            if i == index && (fromFirst && addedVote.name == origName || pId == pollId) then
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

        AddAnotherPersonRow pollId ->
            let
                doFn project changes viewState =
                    let
                        fromFirst =
                            isFirstPoll pollId project.polls

                        updateAddedPersonRows pId addedVotes =
                            if fromFirst || pId == pollId then
                                addedVotes ++ [ { name = "", selectedOptions = Dict.empty } ]

                            else
                                addedVotes

                        updateChangesItem id changesItem =
                            { changesItem | addedPersonRows = updateAddedPersonRows (PollId id) changesItem.addedPersonRows }

                        updatedChanges =
                            Dict.map updateChangesItem changes.changesInPolls
                    in
                    Loaded project { changes | changesInPolls = updatedChanges } viewState
            in
            ( doWithLoadedProject model doFn, Cmd.none )

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
            case model.projectState of
                Saving _ origChanges _ ->
                    let
                        loadResult =
                            loadProject json
                    in
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

                _ ->
                    ( model, Cmd.none )


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



------------------------------------------------------------
---- Common ------------------------------------------------
------------------------------------------------------------
--
-- Convert error or empty string to Nothing, valid string to Just string.


stringToMaybe : String -> Maybe String
stringToMaybe s =
    case s of
        "" ->
            Nothing

        x ->
            Just x


pollIdInt : PollId -> Int
pollIdInt (PollId id) =
    id


personIdInt : PersonId -> Int
personIdInt (PersonId id) =
    id


commentIdInt : CommentId -> Int
commentIdInt (CommentId id) =
    id


optionIdInt : OptionId -> Int
optionIdInt (OptionId id) =
    id


isFirstPoll : PollId -> List Poll -> Bool
isFirstPoll pollId polls =
    Maybe.withDefault False <| Maybe.map (\p -> p.pollId == pollId) <| List.head polls


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


withLast : (a -> b) -> b -> List a -> b
withLast fn default list =
    List.foldl (\item acc -> fn item) default list



-- Normalize changes so that thay contain only selected options that differ from persisted project.


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



------------------------------------------------------------
---- Transforms --------------------------------------------
------------------------------------------------------------


decodePollInfo : D.Decoder PollInfo
decodePollInfo =
    let
        strictDayDecoder =
            let
                beStrict maybeSDay =
                    case maybeSDay of
                        Just sDay ->
                            D.succeed sDay

                        Nothing ->
                            D.fail "invalid day encountered"
            in
            D.andThen beStrict decodeDay

        decodeDayItem =
            D.map2 DateOptionItem
                (D.map OptionId <| D.field "id" D.int)
                (D.field "value" strictDayDecoder)

        decodeStringItem =
            D.map2 GenericOptionItem
                (D.map OptionId <| D.field "id" D.int)
                (D.field "value" D.string)

        datePollInfoDecoder =
            D.map (\l -> DatePollInfo { items = l }) <|
                D.field "items" (D.list decodeDayItem)

        genericPollInfoDecoder =
            D.map (\l -> GenericPollInfo { items = l }) <|
                D.field "items" (D.list decodeStringItem)

        choose type_ =
            case type_ of
                "date" ->
                    datePollInfoDecoder

                "generic" ->
                    genericPollInfoDecoder

                _ ->
                    genericPollInfoDecoder
    in
    D.andThen choose <| D.field "type" D.string


decodeSelectedOption : D.Decoder SelectedOption
decodeSelectedOption =
    let
        convert s =
            case s of
                "yes" ->
                    Yes

                "ifNeeded" ->
                    IfNeeded

                _ ->
                    No
    in
    D.map convert D.string


decodePersonRow : D.Decoder PersonRow
decodePersonRow =
    let
        pairsDecoder : D.Decoder (List ( String, SelectedOption ))
        pairsDecoder =
            D.keyValuePairs decodeSelectedOption

        foldFn : ( String, SelectedOption ) -> Maybe (Dict Int SelectedOption) -> Maybe (Dict Int SelectedOption)
        foldFn ( strKey, value ) acc =
            case String.toInt strKey of
                Nothing ->
                    Nothing

                Just i ->
                    Maybe.map (\d -> Dict.insert i value d) acc

        pairsToDict : List ( String, SelectedOption ) -> D.Decoder (Dict Int SelectedOption)
        pairsToDict pairs =
            let
                dictionary : Maybe (Dict Int SelectedOption)
                dictionary =
                    List.foldl foldFn (Just Dict.empty) pairs
            in
            case dictionary of
                Just d ->
                    D.succeed d

                Nothing ->
                    D.fail "all option keys have to be convertible to integers"

        votesDictDecoder : D.Decoder (Dict Int SelectedOption)
        votesDictDecoder =
            D.andThen pairsToDict pairsDecoder
    in
    D.map3 PersonRow
        (D.map PersonId <| D.field "id" D.int)
        (D.field "name" D.string)
        (D.field "options" votesDictDecoder)


decodePoll : D.Decoder Poll
decodePoll =
    D.map5 Poll
        (D.map PollId <| D.field "id" D.int)
        (D.map stringToMaybe <| D.field "title" D.string)
        (D.field "def" decodePollInfo)
        (D.field "people" <| D.list decodePersonRow)
        (D.field "lastPersonId" D.int)


decodeComment : D.Decoder Comment
decodeComment =
    D.map2 Comment
        (D.map CommentId <| D.field "id" D.int)
        (D.field "text" D.string)


decodeProject : D.Value -> Result D.Error Project
decodeProject json =
    let
        projectDecoder =
            D.map6 Project
                (D.map stringToMaybe (D.field "title" <| D.string))
                (D.field "polls" <| D.list decodePoll)
                (D.field "lastPollId" D.int)
                (D.field "comments" <| D.list decodeComment)
                (D.field "lastCommentId" D.int)
                (D.field "evidence" D.string)
    in
    D.decodeValue projectDecoder json


encodeProject : Project -> E.Value
encodeProject project =
    let
        encodeGenericItem : GenericOptionItem -> E.Value
        encodeGenericItem item =
            E.object
                [ ( "id", E.int <| optionIdInt item.optionId )
                , ( "value", E.string item.value )
                ]

        encodeDateItem : DateOptionItem -> E.Value
        encodeDateItem item =
            E.object
                [ ( "id", E.int <| optionIdInt item.optionId )
                , ( "value", encodeDayTuple <| dayToTuple item.value )
                ]

        encodePollInfo : PollInfo -> E.Value
        encodePollInfo info =
            case info of
                GenericPollInfo { items } ->
                    E.object
                        [ ( "type", E.string "generic" )
                        , ( "items", E.list encodeGenericItem items )
                        , ( "lastItemId", E.int <| withLast (\i -> optionIdInt i.optionId) 0 items )
                        ]

                DatePollInfo { items } ->
                    E.object
                        [ ( "type", E.string "date" )
                        , ( "items", E.list encodeDateItem items )
                        , ( "lastItemId", E.int <| withLast (\i -> optionIdInt i.optionId) 0 items )
                        ]

        selectedOptionToString selectedOption =
            case selectedOption of
                Yes ->
                    "yes"

                No ->
                    "no"

                IfNeeded ->
                    "ifNeeded"

        encodeSelectedOptions : Dict Int SelectedOption -> E.Value
        encodeSelectedOptions selectedOptions =
            E.dict String.fromInt (\v -> selectedOptionToString v |> E.string) selectedOptions

        encodePersonRow : PersonRow -> E.Value
        encodePersonRow personRow =
            E.object
                [ ( "id", E.int <| personIdInt personRow.personId )
                , ( "name", E.string personRow.name )
                , ( "options", encodeSelectedOptions personRow.selectedOptions )
                ]

        encodePoll : Poll -> E.Value
        encodePoll { pollId, title, pollInfo, personRows, lastPersonId } =
            E.object
                [ ( "title", E.string <| Maybe.withDefault "" title )
                , ( "def", encodePollInfo pollInfo )
                , ( "id", E.int <| pollIdInt pollId )
                , ( "lastPersonId", E.int lastPersonId )
                , ( "people", E.list encodePersonRow personRows )
                ]

        encodeComment : Comment -> E.Value
        encodeComment comment =
            E.object
                [ ( "id", E.int <| commentIdInt comment.commentId )
                , ( "text", E.string comment.text )
                ]
    in
    E.object
        [ ( "title", E.string <| Maybe.withDefault "" project.title )
        , ( "polls", E.list encodePoll project.polls )
        , ( "lastPollId", E.int project.lastPollId )
        , ( "comments", E.list encodeComment project.comments )
        , ( "lastCommentId", E.int project.lastCommentId )
        , ( "evidence", E.string project.evidence )
        ]


encodeProjectAndKeys : Project -> Keys -> E.Value
encodeProjectAndKeys project keys =
    E.object
        [ ( "project", encodeProject project )
        , ( "projectKey", E.string keys.projectKey )
        , ( "secretKey", E.string keys.secretKey )
        ]


loadProject json =
    let
        decodeResult =
            decodeProject json
    in
    case decodeResult of
        Ok r ->
            let
                changesForPoll poll =
                    { changesInPersonRows = Dict.empty
                    , addedPersonRows = [ { name = "", selectedOptions = Dict.empty } ]
                    , deletedPersonRows = Set.empty
                    }

                pollId (PollId id) =
                    id

                changes =
                    List.foldl (\curr acc -> Dict.insert (pollId curr.pollId) (changesForPoll curr) acc) Dict.empty r.polls
            in
            Loaded r { changesInPolls = changes, addedComments = [] } Dict.empty

        Err e ->
            Error (D.errorToString e)



------------------------------------------------------------
---- View --------------------------------------------------
------------------------------------------------------------


view model =
    case model.projectState of
        Loading ->
            div []
                [ div [ class "vote-process-overlay" ]
                    [ div [ class "vote-process-overlay-text" ]
                        [ text "Nahrávám" ]
                    ]
                ]

        Error e ->
            div [ class "page-level-error" ] [ text e ]

        Saving project changes states ->
            div []
                [ viewProject project changes states
                , div [ class "vote-process-overlay" ]
                    [ div [ class "vote-process-overlay-text" ]
                        [ text "Ukládám" ]
                    ]
                ]

        Loaded project changes states ->
            viewProject project changes states


viewProject : Project -> ChangesInProject -> ViewStates -> Html Msg
viewProject project changes states =
    let
        changesForPoll (PollId id) =
            Maybe.withDefault emptyChangesInPoll <| Dict.get id changes.changesInPolls

        stateForPoll (PollId id) =
            Maybe.withDefault emptyViewState <| Dict.get id states

        viewForPoll poll =
            viewPoll poll (changesForPoll poll.pollId) (stateForPoll poll.pollId)
    in
    div [ class "vote-project" ]
        [ div [ class "vote-poll-center-outer" ]
            [ div [ class "vote-poll-center" ]
                [ h1 [ class "vote-project-title vote-poll-preferred-width" ]
                    [ text <| Maybe.withDefault "(nepojmenovaný projekt)" project.title
                    ]
                ]
            ]
        , div [ class "vote-polls" ] (List.map viewForPoll project.polls)
        , viewSubmitRow project changes states
        ]


viewPoll : Poll -> ChangesInPoll -> ViewState -> Html Msg
viewPoll poll changes state =
    let
        addedRow index addedVote =
            viewAddedVoteRow poll index addedVote

        addedVotesRows =
            List.indexedMap addedRow changes.addedPersonRows

        changesForPerson personRow =
            Maybe.withDefault emptyChangesInPersonRow <| Dict.get (personIdInt personRow.personId) changes.changesInPersonRows

        isToBeDeleted personRow =
            Set.member (personIdInt personRow.personId) changes.deletedPersonRows

        existingVoteRow personRow =
            viewExistingVoteRow poll personRow (changesForPerson personRow) (isToBeDeleted personRow)

        existingRows =
            List.map existingVoteRow poll.personRows
    in
    div [ class "vote-poll" ]
        [ div [ class "vote-poll-center-outer" ]
            [ div [ class "vote-poll-center" ]
                [ h2 [ class "vote-poll-title vote-poll-preferred-width" ] [ text <| Maybe.withDefault "" poll.title ]
                ]
            ]
        , div [ class "vote-poll-center-outer" ]
            [ div [ class "vote-poll-center" ]
                [ div [ class "vote-poll-preferred-width" ] []
                , table [ class "vote-poll-table" ]
                    ([ viewPollHeader poll state, viewPollResults poll changes state ] ++ existingRows ++ addedVotesRows ++ [ viewAddNewVoteRow poll ])
                ]
            ]
        ]


viewPollHeader : Poll -> ViewState -> Html Msg
viewPollHeader poll state =
    let
        weekDayToString wd =
            case wd of
                0 ->
                    "Po"

                1 ->
                    "Út"

                2 ->
                    "St"

                3 ->
                    "Čt"

                4 ->
                    "Pá"

                5 ->
                    "So"

                6 ->
                    "Ne"

                _ ->
                    "Error"

        dateToString ( year, month, day ) =
            String.join ""
                [ String.fromInt day
                , ". "
                , String.fromInt month
                , ". "
                ]

        dateTupleCell dayInWeek dateString =
            th [ class "vote-poll-header-cell" ]
                [ div [ class "vote-poll-day-in-week" ] [ text <| weekDayToString dayInWeek ]
                , text dateString
                ]

        dateCell { optionId, value } =
            dateTupleCell (weekDay value) (dateToString <| dayToTuple value)

        dateHeader items =
            tr [] ([ th [] [] ] ++ List.map dateCell items)

        genericCell item =
            th [ class "vote-poll-header-cell vote-poll-header-cell-generic" ] [ text item.value ]

        genericHeader items =
            tr [] ([ th [] [] ] ++ List.map genericCell items ++ [ th [] [] ])
    in
    case poll.pollInfo of
        DatePollInfo { items } ->
            dateHeader items

        GenericPollInfo { items } ->
            genericHeader items


viewPollResults : Poll -> ChangesInPoll -> ViewState -> Html Msg
viewPollResults poll changesInPoll state =
    let
        emptyCell =
            td [] []

        merged =
            mergePollWithChanges poll changesInPoll

        allIds =
            pollOptionIds poll

        counter : Int -> PersonRow -> ( Int, Int ) -> ( Int, Int )
        counter optionId personRow ( positiveCount, yesCount ) =
            let
                optionValue =
                    Dict.get optionId personRow.selectedOptions

                updatedPositiveCount =
                    case optionValue of
                        Just Yes ->
                            positiveCount + 1

                        Just IfNeeded ->
                            positiveCount + 1

                        _ ->
                            positiveCount

                updatedYesCount =
                    case optionValue of
                        Just Yes ->
                            yesCount + 1

                        _ ->
                            yesCount
            in
            ( updatedPositiveCount, updatedYesCount )

        countVotes optionId =
            List.foldl (counter <| optionIdInt optionId) ( 0, 0 ) merged.personRows

        counts =
            List.map countVotes allIds

        max =
            List.maximum counts

        countCell : ( Int, Int ) -> Html Msg
        countCell count =
            let
                isMax =
                    Just count == max

                classes =
                    if isMax then
                        "vote-poll-count-cell vote-poll-count-cell-max"

                    else
                        "vote-poll-count-cell"
            in
            td [ class classes ]
                [ span [ class "vote-poll-count-positive" ] [ text <| String.fromInt <| Tuple.first count ]
                , span [ class "vote-poll-count-yes" ] [ text "(", text <| String.fromInt <| Tuple.second count, text ")" ]
                ]

        resultCells =
            List.map countCell counts
    in
    tr [] ((emptyCell :: resultCells) ++ [ emptyCell ])


changedToClass changed =
    if changed then
        " changed"

    else
        ""


viewCellYes : Bool -> Msg -> Html Msg
viewCellYes changed toggleMsg =
    td
        [ class <| "vote-poll-select-cell vote-poll-select-cell-yes" ++ changedToClass changed
        , onClick toggleMsg
        , title "Ano"
        ]
        [ svg [ SAttr.class "vote-poll-select-cell-svg-yes", SAttr.width "20", SAttr.height "20", SAttr.viewBox "0 0 20 20" ]
            [ circle [ SAttr.cx "10", SAttr.cy "10", SAttr.r "7" ] []
            ]
        ]


viewCellNo : Bool -> Msg -> Html Msg
viewCellNo changed toggleMsg =
    td
        [ class <| "vote-poll-select-cell vote-poll-select-cell-no" ++ changedToClass changed
        , onClick toggleMsg
        , title "Ne"
        ]
        [ svg [ SAttr.class "vote-poll-select-cell-svg-no", SAttr.width "20", SAttr.height "20", SAttr.viewBox "0 0 20 20" ]
            [ line [ SAttr.x1 "4", SAttr.y1 "4", SAttr.x2 "16", SAttr.y2 "16" ] []
            , line [ SAttr.x1 "4", SAttr.y1 "16", SAttr.x2 "16", SAttr.y2 "4" ] []
            ]
        ]


viewCellIfNeeded : Bool -> Msg -> Html Msg
viewCellIfNeeded changed toggleMsg =
    td
        [ class <| "vote-poll-select-cell vote-poll-select-cell-ifneeded" ++ changedToClass changed
        , onClick toggleMsg
        , title "V nouzi"
        ]
        [ svg [ SAttr.class "vote-poll-select-cell-svg-ifneeded", SAttr.width "20", SAttr.height "20", SAttr.viewBox "0 0 20 20" ]
            [ circle [ SAttr.cx "10", SAttr.cy "10", SAttr.r "7" ] []
            ]
        ]


viewAddedVoteRow : Poll -> Int -> AddedPersonRow -> Html Msg
viewAddedVoteRow poll addedVoteIndex addedPersonRow =
    let
        isInvalid =
            isInvalidAddedPersonRow addedPersonRow

        validClass =
            if isInvalid then
                " vote-poll-new-name-input-invalid"

            else
                ""

        placeholderText =
            if isInvalid then
                "Vyplňte jméno!"

            else
                "(nový záznam)"

        nameInput =
            input
                [ type_ "text"
                , value addedPersonRow.name
                , class <| "vote-poll-new-name-input" ++ validClass
                , onInput <| SetAddedPersonRowName poll.pollId addedVoteIndex
                , placeholder placeholderText
                ]
                []

        changed =
            not <| String.isEmpty <| String.trim <| addedPersonRow.name

        itemIds =
            case poll.pollInfo of
                DatePollInfo { items } ->
                    List.map .optionId items

                GenericPollInfo { items } ->
                    List.map .optionId items

        optionToCell (OptionId id) =
            case Maybe.withDefault No <| Dict.get id addedPersonRow.selectedOptions of
                Yes ->
                    viewCellYes changed (SetAddedPersonRowOption poll.pollId addedVoteIndex (OptionId id) IfNeeded)

                No ->
                    viewCellNo changed (SetAddedPersonRowOption poll.pollId addedVoteIndex (OptionId id) Yes)

                IfNeeded ->
                    viewCellIfNeeded changed (SetAddedPersonRowOption poll.pollId addedVoteIndex (OptionId id) No)

        selectCells =
            List.map optionToCell itemIds

        editCell =
            td [ class "vote-poll-edit-cell" ]
                [ a [ class "vote-poll-edit-link", onClick (DeleteAddedPersonRow poll.pollId addedVoteIndex) ]
                    [ text "Smaž" ]
                ]
    in
    tr [] (td [ class "vote-poll-name-cell" ] [ nameInput ] :: (selectCells ++ [ editCell ]))


viewExistingVoteRow : Poll -> PersonRow -> ChangesInPersonRow -> Bool -> Html Msg
viewExistingVoteRow poll personRow changesInPersonRow deleted =
    let
        personId =
            personRow.personId

        nameToDisplay =
            Maybe.withDefault personRow.name changesInPersonRow.changedName

        nameInput =
            input
                [ type_ "text"
                , value nameToDisplay
                , class <| "vote-poll-existing-name-input" ++ (changedToClass <| nameToDisplay /= personRow.name && nameToDisplay /= "")
                , onInput <| SetExistingPersonRowName poll.pollId personRow.personId
                , placeholder personRow.name
                , disabled deleted
                ]
                []

        nameCell =
            td [] [ nameInput ]

        allIds =
            pollOptionIds poll

        optionCell optionId =
            let
                changedMaybe =
                    Dict.get (optionIdInt optionId) changesInPersonRow.changedOptions

                selectedMaybe =
                    Dict.get (optionIdInt optionId) personRow.selectedOptions

                original =
                    Maybe.withDefault No selectedMaybe

                actual =
                    Maybe.withDefault original changedMaybe

                changed =
                    original /= actual
            in
            case actual of
                Yes ->
                    viewCellYes changed <| SetExistingPersonRowOption poll.pollId personId optionId IfNeeded

                No ->
                    viewCellNo changed <| SetExistingPersonRowOption poll.pollId personId optionId Yes

                IfNeeded ->
                    viewCellIfNeeded changed <| SetExistingPersonRowOption poll.pollId personId optionId No

        optionCells =
            if deleted then
                [ td [ class "vote-poll-select-cell vote-poll-deleted-cell", colspan <| List.length allIds ] [ text "Ke smazání" ] ]

            else
                List.map optionCell allIds

        editCell =
            if deleted then
                td [ class "vote-poll-edit-cell" ]
                    [ a [ class "vote-poll-edit-link", onClick (UndeleteExistingPersonRow poll.pollId personId) ]
                        [ text "Vrať" ]
                    ]

            else
                td [ class "vote-poll-edit-cell" ]
                    [ a [ class "vote-poll-edit-link", onClick (DeleteExistingPersonRow poll.pollId personId) ]
                        [ text "Smaž" ]
                    ]
    in
    tr [] ((nameCell :: optionCells) ++ [ editCell ])


viewAddNewVoteRow : Poll -> Html Msg
viewAddNewVoteRow poll =
    let
        nameCell =
            td [ class "vote-poll-edit-cell" ]
                [ a [ class "vote-poll-edit-link", onClick (AddAnotherPersonRow poll.pollId) ]
                    [ text "Ještě přidej"
                    ]
                ]

        cols =
            case poll.pollInfo of
                GenericPollInfo { items } ->
                    List.length items

                DatePollInfo { items } ->
                    List.length items

        spanCell =
            td [ colspan cols ] []

        editCell =
            td [] []
    in
    tr []
        [ nameCell
        , spanCell
        , editCell
        ]


viewSubmitRow : Project -> ChangesInProject -> ViewStates -> Html Msg
viewSubmitRow project changesInProject viewState =
    let
        actChanges =
            actualChanges changesInProject project

        hasAddedRow changesItem =
            List.any (\av -> not <| String.isEmpty <| String.trim av.name) changesItem.addedPersonRows

        hasDeletedRow changesItem =
            not <| Set.isEmpty changesItem.deletedPersonRows

        hasModifiedRow changesItem =
            not <| Dict.isEmpty changesItem.changesInPersonRows

        pollHasChange _ changesItem prev =
            prev || hasAddedRow changesItem || hasDeletedRow changesItem || hasModifiedRow changesItem

        hasAddedComments =
            not <| List.isEmpty actChanges.addedComments

        hasChanges =
            Dict.foldl pollHasChange False actChanges.changesInPolls || hasAddedComments

        isInvalid =
            containsInvalidChange actChanges

        enabled =
            hasChanges && not isInvalid

        boolToString s =
            if s then
                "true"

            else
                "false"
    in
    div [ class "vote-poll-center-outer" ]
        [ div [ class "vote-poll-center" ]
            [ div [ class "submit-row vote-poll-preferred-width" ]
                [ button [ class "submit-button common-button colors-edit", disabled <| not enabled, onClick SaveChanges ]
                    [ text "Uložit změny" ]
                ]
            ]
        ]



------------------------------------------------------------
---- Program -----------------------------------------------
------------------------------------------------------------


main : Program D.Value Model Msg
main =
    Browser.element { init = init, update = update, view = view, subscriptions = subscriptions }
