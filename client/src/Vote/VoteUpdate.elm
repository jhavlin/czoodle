port module Vote.VoteUpdate exposing (Msg(..), init, subscriptions, update)

import Candidate.DateCandidate.SDate exposing (SDay, dayFromTuple, defaultDay)
import Common.CommonDecoders exposing (decodeDay)
import Data.CandidateId exposing (CandidateId(..))
import Data.Comments exposing (RowComment(..), VoteComment(..))
import Data.DataModel
    exposing
        ( CandidatesInfo(..)
        , Poll
        , PollId(..)
        , Project
        , Voter
        , pollIdInt
        )
import Data.PollRows exposing (VoterRowStatus(..))
import Data.VoterId exposing (VoterId(..), voterIdInt)
import Dict exposing (Dict)
import EditProject.EditProjectModel exposing (mergeProjectWithDefinitionChanges)
import EditProject.EditProjectUpdate exposing (init, update)
import Json.Decode as D
import Json.Encode as E
import Poll.PollKinds as PollKinds exposing (KindOfChangedVoterRow, KindOfPollInnerMsg, KindOfVoterRow(..), KindOfVotesInfo(..))
import Poll.YesNoPoll.YesNoPollData exposing (YesNoOption(..))
import Set
import Task
import Translations.Translations as Translations
import Translations.TranslationsDecoders exposing (decodeTranslation)
import Vote.VoteModel exposing (ChangesInProject(..), Model, ProjectState(..), ViewState, ViewStates)


port load : E.Value -> Cmd msg


port modify : E.Value -> Cmd msg


port loaded : (D.Value -> msg) -> Sub msg


port hashChanged : (D.Value -> msg) -> Sub msg


port modified : (D.Value -> msg) -> Sub msg


port updatedVersionReceived : (D.Value -> msg) -> Sub msg


type Msg
    = NoOp
    | NoOpJson D.Value
    | LoadedData D.Value
    | HashChanged D.Value
    | MakeVoterEditable VoterId
    | MakeVoterNotEditable VoterId
    | AddedPersonInnerPollMsg PollId KindOfPollInnerMsg
    | SetAddedPersonName String
    | RevertChanges
    | ExistingPersonInnerPollMsg VoterId PollId KindOfPollInnerMsg
    | SetExistingVoterName VoterId String
    | SkipVoterRow VoterId PollId
    | UnSkipVoterRow VoterId PollId
    | SaveChanges
    | RetrySaveChanges D.Value
    | SwitchToDefinitionEditor
    | SwitchToVotesEditor Bool
    | SaveProjectDefinitionChanges
    | EditProjectMsg EditProject.EditProjectModel.Msg
    | SetTranslation String


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

        projectState : ProjectState
        projectState =
            case urlHashResult of
                Ok _ ->
                    -- TODO
                    -- Loading
                    exampleProjectState

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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SaveChanges ->
            ( model, modify (E.object []) )

        _ ->
            -- TODO remove default option
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        []


exampleProjectState : ProjectState
exampleProjectState =
    let
        poll1 : Poll
        poll1 =
            { pollId = PollId 1
            , title = Just "Datum foceni"
            , description = Just ""
            , pollInfo =
                { candidatesInfo =
                    DateCandidatesInfo
                        [ { candidateId = CandidateId 1
                          , value = dayFromTuple ( 2025, 11, 11 ) |> Maybe.withDefault defaultDay
                          , hidden = False
                          }
                        , { candidateId = CandidateId 2
                          , value = dayFromTuple ( 2025, 11, 13 ) |> Maybe.withDefault defaultDay
                          , hidden = False
                          }
                        ]
                , votesInfo =
                    YesNoVotesInfo
                        { settings = { allowIfNeeded = True, allowMaybe = False }
                        , votes =
                            Dict.fromList
                                [ ( 1, { voterVotes = Dict.fromList [ ( 1, { comment = VoteComment "", vote = Yes } ) ], rowComment = RowComment "", status = Valid } )
                                , ( 2, { voterVotes = Dict.fromList [ ( 1, { comment = VoteComment "Cool", vote = No } ) ], rowComment = RowComment "", status = Valid } )
                                ]
                        }
                }
            }

        poll2 : Poll
        poll2 =
            { pollId = PollId 1
            , title = Just "Zvire"
            , description = Just ""
            , pollInfo =
                { candidatesInfo =
                    TextCandidatesInfo
                        [ { candidateId = CandidateId 1
                          , value = "Veverka"
                          , hidden = False
                          }
                        , { candidateId = CandidateId 2
                          , value = "Nutrie"
                          , hidden = False
                          }
                        ]
                , votesInfo =
                    YesNoVotesInfo
                        { settings = { allowIfNeeded = True, allowMaybe = False }
                        , votes =
                            Dict.fromList
                                [ ( 1
                                  , { voterVotes =
                                        Dict.fromList
                                            [ ( 1, { comment = VoteComment "", vote = IfNeeded } )
                                            , ( 2, { comment = VoteComment "", vote = IfNeeded } )
                                            ]
                                    , rowComment = RowComment "I do not care much"
                                    , status = Valid
                                    }
                                  )
                                , ( 2
                                  , { voterVotes =
                                        Dict.fromList
                                            [ ( 1, { comment = VoteComment "", vote = Yes } )
                                            , ( 2, { comment = VoteComment "", vote = No } )
                                            ]
                                    , rowComment = RowComment "Veverka FTW"
                                    , status = Valid
                                    }
                                  )
                                ]
                        }
                }
            }

        voters : List Voter
        voters =
            [ { voterId = VoterId 1, name = "Pat" }, { voterId = VoterId 2, name = "Mat" } ]

        project : Project
        project =
            { title = Just "Sample hardcoded project"
            , polls = [ poll1, poll2 ]
            , voters = voters
            , lastPollId = 2
            , lastVoterId = 1
            }

        changesInProject : ChangesInProject
        changesInProject =
            AddedVoter
                { voterName = "Novy"
                , rowsInPolls =
                    Dict.fromList
                        [ ( 1, YesNoVoterRow { voterVotes = Dict.fromList [ ( 1, { comment = VoteComment "", vote = Yes } ) ], rowComment = RowComment "", status = Valid } )
                        , ( 2, YesNoVoterRow { voterVotes = Dict.fromList [ ( 1, { comment = VoteComment "", vote = Yes } ) ], rowComment = RowComment "", status = Valid } )
                        ]
                }

        viewStates : ViewStates
        viewStates =
            Dict.empty
    in
    Loaded project changesInProject viewStates
