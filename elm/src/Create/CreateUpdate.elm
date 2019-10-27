port module Create.CreateUpdate exposing (init, subscriptions, update)

import Browser.Dom exposing (getViewportOf)
import Common.ListUtils as ListUtils
import Create.CreateDecoders exposing (..)
import Create.CreateModel exposing (..)
import Data.DataEncoders exposing (encodeProject)
import Dict exposing (..)
import Json.Decode as D
import Json.Encode as E
import SDate.SDate exposing (..)
import Set exposing (..)
import Task exposing (..)


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

        SetPollTitle num title ->
            ( { model | polls = ListUtils.changeIndex (setPollTitle title) num model.polls }, Cmd.none )

        SetPollDescription num description ->
            ( { model | polls = ListUtils.changeIndex (setPollDescription description) num model.polls }, Cmd.none )

        SetGenericPollItem num itemNumber itemVal ->
            ( doWithGenericPoll (setGenericItem itemNumber itemVal) model num, Cmd.none )

        AddGenericPollItem num ->
            ( doWithGenericPoll addGenericItem model num, Cmd.none )

        RemoveGenericPollItem num itemNumber ->
            ( doWithGenericPoll (removeGenericItem itemNumber) model num, Cmd.none )

        AddDatePollItem num dayTuple ->
            ( doWithDatePoll (\data -> { data | items = Set.insert dayTuple data.items }) model num, Cmd.none )

        RemoveDatePollItem num dayTuple ->
            ( doWithDatePoll (\data -> { data | items = Set.remove dayTuple data.items }) model num, Cmd.none )

        SetCalendarMonth num sMonth ->
            ( doWithDatePollState (\state -> { state | month = sMonth }) model num, Cmd.none )

        SetCalendarMonthDirect num str ->
            ( doWithDatePollState (setCalendarMonthDirect str) model num, Cmd.none )

        SetCalendarYearDirect num str ->
            ( doWithDatePollState (setCalendarYearDirect str) model num, Cmd.none )

        SetHighlightedDay num maybeTuple ->
            ( doWithDatePollState (\state -> { state | highlightedDay = maybeTuple }) model num, Cmd.none )

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


doWithGenericPoll : (NewGenericPollData -> NewGenericPollData) -> Model -> Int -> Model
doWithGenericPoll fn model pollNumber =
    let
        checkAndDo newPoll =
            case newPoll.def of
                NewGenericPollModel genericPollData ->
                    { newPoll | def = NewGenericPollModel (fn genericPollData) }

                _ ->
                    newPoll

        polls =
            ListUtils.changeIndex checkAndDo pollNumber model.polls
    in
    { model | polls = polls }


doWithDatePoll : (NewDatePollData -> NewDatePollData) -> Model -> Int -> Model
doWithDatePoll fn model pollNumber =
    let
        checkAndDo newPoll =
            case newPoll.def of
                NewDatePollModel state datePollData ->
                    { newPoll | def = NewDatePollModel state (fn datePollData) }

                _ ->
                    newPoll

        polls =
            ListUtils.changeIndex checkAndDo pollNumber model.polls
    in
    { model | polls = polls }


doWithDatePollState : (CalendarStateModel -> CalendarStateModel) -> Model -> Int -> Model
doWithDatePollState fn model pollNumber =
    let
        checkAndDo newPoll =
            case newPoll.def of
                NewDatePollModel state datePollData ->
                    { newPoll | def = NewDatePollModel (fn state) datePollData }

                _ ->
                    newPoll

        polls =
            ListUtils.changeIndex checkAndDo pollNumber model.polls
    in
    { model | polls = polls }


emptyGenericPoll : NewPoll
emptyGenericPoll =
    { title = "", description = "", def = NewGenericPollModel { items = [ "", "" ] } }


emptyDatePoll : SDay -> NewPoll
emptyDatePoll today =
    let
        state =
            { month = monthFromDay today, highlightedDay = Nothing, today = today }

        def =
            NewDatePollModel state { items = Set.empty }
    in
    { title = "", description = "", def = def }


setPollTitle : String -> NewPoll -> NewPoll
setPollTitle newTitle newPoll =
    { newPoll | title = newTitle }


setPollDescription : String -> NewPoll -> NewPoll
setPollDescription newDescription newPoll =
    { newPoll | description = newDescription }


addGenericItem : NewGenericPollData -> NewGenericPollData
addGenericItem data =
    { data | items = data.items ++ [ "" ] }


setGenericItem : Int -> String -> NewGenericPollData -> NewGenericPollData
setGenericItem itemNumber newValue data =
    { data | items = ListUtils.changeIndex (\_ -> newValue) itemNumber data.items }


removeGenericItem : Int -> NewGenericPollData -> NewGenericPollData
removeGenericItem itemNumber data =
    let
        newItems =
            if List.length data.items > 2 then
                ListUtils.removeIndex itemNumber data.items

            else
                ListUtils.changeIndex (\_ -> "") itemNumber data.items
    in
    { data | items = newItems }


setCalendarMonthDirect : String -> CalendarStateModel -> CalendarStateModel
setCalendarMonthDirect str data =
    let
        ( year, _ ) =
            monthToTuple data.month

        monthOpt =
            String.toInt str

        newMonthOpt =
            Maybe.andThen (\m -> monthFromTuple ( year, m )) monthOpt
    in
    case newMonthOpt of
        Just sMonth ->
            { data | month = sMonth }

        Nothing ->
            data


setCalendarYearDirect : String -> CalendarStateModel -> CalendarStateModel
setCalendarYearDirect str data =
    let
        ( _, month ) =
            monthToTuple data.month

        yearOpt =
            String.toInt str

        newYearOpt =
            Maybe.andThen (\y -> monthFromTuple ( y, month )) yearOpt
    in
    case newYearOpt of
        Just sMonth ->
            { data | month = sMonth }

        Nothing ->
            data
