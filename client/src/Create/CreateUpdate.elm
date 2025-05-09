port module Create.CreateUpdate exposing (init, subscriptions, update)

import Browser.Dom
import Candidate.DateCandidate.SDate exposing (SDay, defaultDay, monthFromDay)
import Common.ListUtils as ListUtils
import Create.CreateDecoders exposing (decodeCreateFlags)
import Create.CreateModel exposing (CreatedProjectInfo, Model, Msg(..), newPollsToProject)
import Data.DataCoding exposing (encodeProject)
import Dict
import Json.Decode as D
import Json.Encode as E
import PollEditor.PollEditorModel exposing (CandidatesEditor(..), PollEditorModel, VotesEditor(..))
import PollEditor.PollEditorUpdate as PollEditorUpdate
import Set
import Task
import Translations.Translations as Translations


port persist : E.Value -> Cmd msg


port createdProjectInfo : (D.Value -> msg) -> Sub msg



---- Init ----


init : D.Value -> ( Model, Cmd Msg )
init jsonFlags =
    let
        flagsResult =
            D.decodeValue decodeCreateFlags jsonFlags

        { today, baseUrl, translation } =
            Result.withDefault { today = defaultDay, baseUrl = "", translation = Translations.default } flagsResult
    in
    ( { title = ""
      , polls = []
      , today = today
      , baseUrl = baseUrl
      , wait = False

      --   , created = Just { projectKey = "196u6", secretKey = "KXM8c0jaaZwJ3IRsTw0uRtJE9zY-l3-WQ8dnOnl07Iw" }
      , created = Nothing
      , translation = translation
      }
    , Cmd.none
    )



---- Subscriptions ----


subscriptions : Model -> Sub Msg
subscriptions _ =
    let
        decoder =
            D.map2 CreatedProjectInfo
                (D.field "projectKey" D.string)
                (D.field "secretKey" D.string)

        decodeCreatedProjectInfo v =
            D.decodeValue decoder v

        decoderResult v =
            case decodeCreatedProjectInfo v of
                Ok value ->
                    value

                Err _ ->
                    { projectKey = "error", secretKey = "error" }
    in
    createdProjectInfo (\v -> ProjectCreated (decoderResult v))



---- Update ----


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        SetTitle newTitle ->
            ( { model | title = newTitle }, Cmd.none )

        AddGenericPoll ->
            ( { model | polls = model.polls ++ [ emptyGenericPoll ] }, Cmd.none )

        AddDatePoll ->
            ( { model | polls = model.polls ++ [ emptyDatePoll model.today ] }, Cmd.none )

        RemovePoll num ->
            ( { model | polls = ListUtils.removeIndex num model.polls }, Cmd.none )

        EditPoll num pollEditorMsg ->
            ( { model | polls = ListUtils.changeIndex (PollEditorUpdate.update pollEditorMsg) num model.polls }, Cmd.none )

        Persist ->
            ( { model | wait = True }, persist <| encodeProject <| newPollsToProject model )

        ProjectCreated projectInfo ->
            let
                scroll id =
                    Browser.Dom.getViewportOf id
                        |> Task.andThen (\info -> Browser.Dom.setViewport 0 info.viewport.y)
                        |> Task.attempt (\_ -> NoOp)
            in
            ( { model | created = Just projectInfo }, scroll "project" )

        SetTranslation code ->
            ( { model | translation = Translations.get code }, Cmd.none )


emptyGenericPoll : PollEditorModel
emptyGenericPoll =
    let
        candidatesEditor =
            TextCandidatesEditor
                { addedItems = [ "", "" ]
                , originalItems = []
                , hiddenItems = Set.empty
                , unhiddenItems = Set.empty
                , renamedItems = Dict.empty
                }

        votesEditor =
            YesNoVotesEditor
    in
    { originalTitle = ""
    , originalDescription = ""
    , changedTitle = Nothing
    , changedDescription = Nothing
    , candidatesEditor = candidatesEditor
    , votesEditor = votesEditor
    }


emptyDatePoll : SDay -> PollEditorModel
emptyDatePoll today =
    let
        data =
            { addedItems = Set.empty
            , originalItems = []
            , hiddenItems = Set.empty
            , unhiddenItems = Set.empty
            }

        state =
            { month = monthFromDay today, highlightedDay = Nothing, today = today }

        candidatesEditor =
            DateCandidatesEditor { data = data, state = state }

        votesEditor =
            YesNoVotesEditor
    in
    { originalTitle = ""
    , originalDescription = ""
    , changedTitle = Nothing
    , changedDescription = Nothing
    , candidatesEditor = candidatesEditor
    , votesEditor = votesEditor
    }
