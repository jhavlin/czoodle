module Create.CreateModel exposing
    ( CreatedProjectInfo
    , Model
    , Msg(..)
    , newPollsToProject
    )

import Common.CommonUtils exposing (normalizeStringMaybe, stringToMaybe)
import Common.ListUtils exposing (filterNothings)
import Data.DataModel exposing (OptionId(..), Poll, PollId(..), PollInfo(..), Project)
import PollEditor.PollEditorModel exposing (PollEditor(..), PollEditorModel, PollEditorMsg)
import SDate.SDate exposing (SDay, dayFromTuple)
import Set
import Translations.Translation exposing (Translation)



{-
   -
   -Types
   -
-}


type Msg
    = SetTitle String
    | AddGenericPoll
    | AddDatePoll
    | RemovePoll Int
    | EditPoll Int PollEditorMsg
    | Persist
    | ProjectCreated CreatedProjectInfo
    | SetTranslation String
    | NoOp


type alias CreatedProjectInfo =
    { projectKey : String
    , secretKey : String
    }


type alias Model =
    { title : String
    , polls : List PollEditorModel
    , today : SDay
    , wait : Bool
    , created : Maybe CreatedProjectInfo
    , baseUrl : String
    , translation : Translation
    }



{-
   -
   - Functions
   -
-}


newPollsToProject : Model -> Project
newPollsToProject { title, polls } =
    let
        newDatePollDataToPollInfo { addedItems } =
            Set.toList addedItems
                |> List.map dayFromTuple
                |> filterNothings
                |> List.indexedMap (\index item -> { optionId = OptionId <| 1 + index, value = item, hidden = False })

        newGenericPollDataToPollInfo { addedItems } =
            List.filter (\v -> not <| String.isEmpty <| String.trim v) addedItems
                |> List.indexedMap (\index item -> { optionId = OptionId <| 1 + index, value = item, hidden = False })

        newPollModelToPollInfo : PollEditor -> PollInfo
        newPollModelToPollInfo pollEditorModel =
            case pollEditorModel of
                DatePollEditor _ newPollData ->
                    DatePollInfo { items = newDatePollDataToPollInfo newPollData }

                GenericPollEditor newPollData ->
                    GenericPollInfo { items = newGenericPollDataToPollInfo newPollData }

        pollEditorModelToPoll : Int -> PollEditorModel -> Poll
        pollEditorModelToPoll index pollEditorModel =
            { pollId = PollId <| index + 1
            , title = normalizeStringMaybe pollEditorModel.changedTitle
            , description = normalizeStringMaybe pollEditorModel.changedDescription
            , pollInfo = newPollModelToPollInfo pollEditorModel.editor
            , personRows = []
            , lastPersonId = 0
            }

        finalPolls =
            List.indexedMap pollEditorModelToPoll polls
    in
    { title = stringToMaybe title
    , polls = finalPolls
    , lastPollId = 1 + List.length finalPolls
    , comments = []
    , lastCommentId = 0
    }
