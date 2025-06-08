module Create.CreateModel exposing
    ( CreatedProjectInfo
    , Model
    , Msg(..)
    , newPollsToProject
    )

import Candidate.DateCandidate.SDate exposing (SDay, dayFromTuple)
import Common.CommonUtils exposing (normalizeStringMaybe, stringToMaybe)
import Common.ListUtils exposing (filterNothings)
import Data.CandidateId exposing (CandidateId(..))
import Data.DataModel exposing (CandidatesInfo(..), Poll, PollId(..), Project)
import Poll.PollKinds exposing (defaultVotesInfo)
import PollEditor.PollEditorModel exposing (CandidatesEditor(..), PollEditorModel, PollEditorMsg)
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
                |> List.indexedMap (\index item -> { candidateId = CandidateId <| 1 + index, value = item, hidden = False })

        newGenericPollDataToPollInfo { addedItems } =
            List.filter (\v -> not <| String.isEmpty <| String.trim v) addedItems
                |> List.indexedMap (\index item -> { candidateId = CandidateId <| 1 + index, value = item, hidden = False })

        newPollModelToCandidatesInfo : PollEditorModel -> CandidatesInfo
        newPollModelToCandidatesInfo pollEditorModel =
            case pollEditorModel.candidatesEditor of
                DateCandidatesEditor newPollData ->
                    DateCandidatesInfo (newDatePollDataToPollInfo newPollData.data)

                TextCandidatesEditor newPollData ->
                    TextCandidatesInfo (newGenericPollDataToPollInfo newPollData)

        pollEditorModelToPoll : Int -> PollEditorModel -> Poll
        pollEditorModelToPoll index pollEditorModel =
            { pollId = PollId <| index + 1
            , title = normalizeStringMaybe pollEditorModel.changedTitle
            , description = normalizeStringMaybe pollEditorModel.changedDescription
            , pollInfo =
                { candidatesInfo = newPollModelToCandidatesInfo pollEditorModel
                , votesInfo = defaultVotesInfo
                }
            }

        finalPolls =
            List.indexedMap pollEditorModelToPoll polls
    in
    { title = stringToMaybe title
    , polls = finalPolls
    , lastPollId = 1 + List.length finalPolls
    , voters = []
    , lastVoterId = 1
    }
