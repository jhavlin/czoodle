port module Create.CreateUpdate exposing (init, subscriptions, update)

import Browser.Dom exposing (getViewportOf)
import Common.ListUtils as ListUtils
import Create.CreateDecoders exposing (decodeCreateFlags)
import Create.CreateModel exposing (CreatedProjectInfo, Model, Msg(..), newPollsToProject)
import Data.DataEncoders exposing (encodeProject)
import Dict
import Json.Decode as D
import Json.Encode as E
import PollEditor.PollEditorModel exposing (PollEditor(..), PollEditorModel)
import PollEditor.PollEditorUpdate as PollEditorUpdate exposing (update)
import SDate.SDate exposing (SDay, defaultDay, monthFromDay)
import Set
import Task


port persist : E.Value -> Cmd msg


port createdProjectInfo : (D.Value -> msg) -> Sub msg



---- Init ----


init : D.Value -> ( Model, Cmd Msg )
init jsonFlags =
    let
        flagsResult =
            D.decodeValue decodeCreateFlags jsonFlags

        { today, baseUrl } =
            Result.withDefault { today = defaultDay, baseUrl = "" } flagsResult
    in
    ( { title = ""
      , polls = []
      , today = today
      , baseUrl = baseUrl
      , wait = False

      --   , created = Just { projectKey = "196u6", secretKey = "KXM8c0jaaZwJ3IRsTw0uRtJE9zY-l3-WQ8dnOnl07Iw" }
      , created = Nothing
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


emptyGenericPoll : PollEditorModel
emptyGenericPoll =
    let
        editor =
            GenericPollEditor
                { addedItems = [ "", "" ]
                , originalItems = []
                , hiddenItems = Set.empty
                , unhiddenItems = Set.empty
                , renamedItems = Dict.empty
                }
    in
    { originalTitle = "", originalDescription = "", changedTitle = Nothing, changedDescription = Nothing, editor = editor }


emptyDatePoll : SDay -> PollEditorModel
emptyDatePoll today =
    let
        state =
            { month = monthFromDay today, highlightedDay = Nothing, today = today }

        editor =
            DatePollEditor state
                { addedItems = Set.empty
                , originalItems = []
                , hiddenItems = Set.empty
                , unhiddenItems = Set.empty
                }
    in
    { originalTitle = "", originalDescription = "", changedTitle = Nothing, changedDescription = Nothing, editor = editor }
