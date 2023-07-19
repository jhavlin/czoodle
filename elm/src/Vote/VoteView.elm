module Vote.VoteView exposing (view)

import Array
import Common.CommonView
    exposing
        ( changedToClass
        , editableToClass
        , invisibleToClass
        , transparentToClass
        )
import Data.DataModel
    exposing
        ( OptionId(..)
        , PersonId(..)
        , PersonRow
        , Poll
        , PollId(..)
        , PollInfo(..)
        , Project
        , SelectedOption(..)
        , optionIdInt
        , personIdInt
        )
import Dict
import EditProject.EditProjectView as EditProjectView
import Html exposing (Html, a, button, div, h1, h2, input, span, table, td, text, th, tr)
import Html.Attributes exposing (class, colspan, disabled, placeholder, title, type_, value)
import Html.Events exposing (onClick, onInput)
import SDate.SDate exposing (dayToTuple, weekDay)
import Set
import Svg exposing (circle, line, svg)
import Svg.Attributes as SAttr
import Translations.Translation exposing (Translation)
import Translations.TranslationsView exposing (translationsView)
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
        , emptyChangesInPersonRow
        , emptyChangesInPoll
        , emptyViewState
        , hasChangesInVotes
        , isInvalidAddedPersonRow
        , isValidVotingState
        , mergePollWithChanges
        , pollOptionIds
        )



{- Helper type for passing state and pre-computed info between functions -}


type alias ViewModel =
    { project : Project
    , changesInProject : ChangesInProject
    , viewStates : ViewStates
    , isValidVotingState : Bool
    , hasChangesInVotes : Bool
    , translation : Translation
    }


view : Model -> Html Msg
view model =
    let
        viewModel project changesInProject viewStates translation =
            let
                normalizedChanges =
                    actualChanges changesInProject project
            in
            { project = project
            , changesInProject = normalizedChanges
            , viewStates = viewStates
            , isValidVotingState = isValidVotingState normalizedChanges
            , hasChangesInVotes = hasChangesInVotes normalizedChanges
            , translation = translation
            }
    in
    case model.projectState of
        Loading ->
            div []
                [ div [ class "vote-process-overlay" ]
                    [ div [ class "vote-process-overlay-text" ]
                        [ text model.translation.vote.loading ]
                    ]
                ]

        Error e ->
            div [ class "page-level-error" ] [ text e ]

        Saving project changes states ->
            div []
                [ viewProject <| viewModel project changes states model.translation
                , div [ class "vote-process-overlay" ]
                    [ div [ class "vote-process-overlay-text" ]
                        [ text model.translation.vote.saving ]
                    ]
                ]

        Loaded project changes states ->
            div []
                [ viewTranslate model
                , viewProject <| viewModel project changes states model.translation
                ]

        Editing project changesInProjectDefinition ->
            div []
                [ viewTranslate model
                , EditProjectView.view project
                    changesInProjectDefinition
                    { outerMessage = EditProjectMsg
                    , switchBackMessage = SwitchToVotesEditor
                    , saveMessage = SaveProjectDefinitionChanges
                    , today = model.today
                    , translation = model.translation
                    }
                ]

        SavingDefinition project changesInProjectDefinition ->
            div []
                [ EditProjectView.view project
                    changesInProjectDefinition
                    { outerMessage = EditProjectMsg
                    , switchBackMessage = SwitchToVotesEditor
                    , saveMessage = SaveProjectDefinitionChanges
                    , today = model.today
                    , translation = model.translation
                    }
                , div [ class "vote-process-overlay" ]
                    [ div [ class "vote-process-overlay-text" ]
                        [ text model.translation.vote.saving ]
                    ]
                ]


viewTranslate : Model -> Html Msg
viewTranslate model =
    div [ class "vote-poll-center-outer" ]
        [ div [ class "vote-poll-preferred-width relative" ]
            [ translationsView model.translation SetTranslation ]
        ]


viewProject : ViewModel -> Html Msg
viewProject viewModel =
    let
        { project, changesInProject, viewStates, hasChangesInVotes } =
            viewModel

        changesForPoll (PollId id) =
            Maybe.withDefault emptyChangesInPoll <| Dict.get id changesInProject.changesInPolls

        stateForPoll (PollId id) =
            Maybe.withDefault emptyViewState <| Dict.get id viewStates

        viewForPoll pollIndex poll =
            viewPoll pollIndex poll (changesForPoll poll.pollId) (stateForPoll poll.pollId) viewModel.translation
    in
    div [ class "vote-project" ]
        [ div [ class "vote-poll-center-outer" ]
            [ div [ class "vote-poll-center" ]
                [ div [ class "vote-poll-preferred-width vote-project-title-line" ]
                    [ div [ class "vote-project-title-cell" ]
                        [ h1 [ class "vote-project-title" ] [ text <| Maybe.withDefault viewModel.translation.common.untitled project.title ]
                        ]
                    , div [ class ("vote-project-edit-cell" ++ invisibleToClass hasChangesInVotes) ]
                        [ a
                            [ class "vote-project-edit-button"
                            , title viewModel.translation.vote.editProjectTitle
                            , onClick SwitchToDefinitionEditor
                            ]
                            [ text "✎" ]
                        ]
                    ]
                , legend viewModel.translation
                ]
            ]
        , div [ class "vote-polls" ] (List.indexedMap viewForPoll project.polls)
        , viewSubmitRow viewModel
        ]


legend : Translation -> Html Msg
legend translation =
    div [ class "vote-legend" ]
        [ table []
            [ tr []
                [ td [ class "vote-legend-text" ] [ text translation.vote.legend, text ": " ]
                , viewCellYes False False "" NoOp translation
                , td [ class "vote-legend-text" ] [ text translation.vote.yes, text " " ]
                , viewCellIfNeeded False False "" NoOp translation
                , td [ class "vote-legend-text" ] [ text translation.vote.ifNeeded, text " " ]
                , viewCellNo False False "" NoOp translation
                , td [ class "vote-legend-text" ] [ text translation.vote.no, text " " ]
                ]
            ]
        ]


viewPoll : Int -> Poll -> ChangesInPoll -> ViewState -> Translation -> Html Msg
viewPoll pollIndex poll changes state translation =
    let
        emptyCell =
            td [] []

        headerRow =
            viewPollHeader poll state translation

        resultCells =
            viewPollResultCells poll changes state

        resultsRow =
            if pollIndex == 0 then
                tr [] ((viewAddNewVoteCell changes translation :: resultCells) ++ [ emptyCell ])

            else
                tr [] ((emptyCell :: resultCells) ++ [ emptyCell ])

        addedRow index addedVote =
            viewAddedVoteRow poll index addedVote translation

        addedVotesRows =
            List.indexedMap addedRow changes.addedPersonRows

        changesForPerson personRow =
            Maybe.withDefault emptyChangesInPersonRow <| Dict.get (personIdInt personRow.personId) changes.changesInPersonRows

        isToBeDeleted personRow =
            Set.member (personIdInt personRow.personId) changes.deletedPersonRows

        isEditable personRow =
            Set.member (personIdInt personRow.personId) state.editableExistingRows

        existingVoteRow personRow =
            viewExistingVoteRow poll personRow (changesForPerson personRow) (isToBeDeleted personRow) (isEditable personRow) translation

        existingRows =
            List.map existingVoteRow poll.personRows

        marginClass =
            if pollIndex > 0 then
                " padding-bottom"

            else
                ""
    in
    div [ class "vote-poll" ]
        [ div [ class "vote-poll-center-outer" ]
            [ div [ class "vote-poll-center" ]
                [ h2 [ class "vote-poll-title vote-poll-preferred-width" ] [ text <| Maybe.withDefault (String.concat [ translation.vote.poll, " ", String.fromInt <| pollIndex + 1 ]) poll.title ]
                , div [ class "vote-poll-description vote-poll-preferred-width" ] [ text <| Maybe.withDefault "" poll.description ]
                ]
            ]
        , div [ class "vote-poll-center-outer" ]
            [ div [ class "vote-poll-center" ]
                [ div [ class "vote-poll-preferred-width" ] []
                , table [ class <| "vote-poll-table" ++ marginClass ]
                    ([ headerRow, resultsRow ] ++ (List.reverse <| existingRows ++ addedVotesRows))
                ]
            ]
        ]


viewPollHeader : Poll -> ViewState -> Translation -> Html Msg
viewPollHeader poll _ translation =
    let
        dayNameArray =
            Array.fromList translation.common.dayNamesShort

        weekDayToString wd =
            Maybe.withDefault translation.common.error <| Array.get wd dayNameArray

        dateToString ( _, month, day ) =
            String.join ""
                [ String.fromInt day
                , ". "
                , String.fromInt month
                , ". "
                ]

        dateTupleCell dayInWeek dateString =
            th []
                [ div [ class "vote-poll-header-cell" ]
                    [ div [ class "vote-poll-day-in-week" ] [ text <| weekDayToString dayInWeek ]
                    , text dateString
                    ]
                ]

        dateCell { value } =
            dateTupleCell (weekDay value) (dateToString <| dayToTuple value)

        dateHeader items =
            tr [] (th [] [] :: List.map dateCell items)

        genericCell item =
            th []
                [ div [ class "vote-poll-header-cell vote-poll-header-cell-generic" ] [ text item.value ]
                ]

        genericHeader items =
            tr [] (th [] [] :: List.map genericCell items ++ [ th [] [] ])
    in
    case poll.pollInfo of
        DatePollInfo { items } ->
            dateHeader <| List.filter (not << .hidden) items

        GenericPollInfo { items } ->
            genericHeader <| List.filter (not << .hidden) items


viewPollResultCells : Poll -> ChangesInPoll -> ViewState -> List (Html Msg)
viewPollResultCells poll changesInPoll _ =
    let
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
    in
    List.map countCell counts


fixTooltip : String -> String -> String
fixTooltip info state =
    if String.isEmpty <| String.trim info then
        state

    else
        info ++ ": " ++ state


viewCellYes : Bool -> Bool -> String -> Msg -> Translation -> Html Msg
viewCellYes changed transparent tooltip toggleMsg translation =
    div
        [ class <| "vote-poll-select-cell vote-poll-select-cell-yes" ++ changedToClass changed ++ transparentToClass transparent
        , onClick toggleMsg
        , title <| fixTooltip tooltip translation.vote.yes
        ]
        [ svg [ SAttr.class "vote-poll-select-cell-svg-yes", SAttr.width "20", SAttr.height "20", SAttr.viewBox "0 0 20 20" ]
            [ circle [ SAttr.cx "10", SAttr.cy "10", SAttr.r "7" ] []
            ]
        ]


viewCellNo : Bool -> Bool -> String -> Msg -> Translation -> Html Msg
viewCellNo changed transparent tooltip toggleMsg translation =
    div
        [ class <| "vote-poll-select-cell vote-poll-select-cell-no" ++ changedToClass changed ++ transparentToClass transparent
        , onClick toggleMsg
        , title <| fixTooltip tooltip translation.vote.no
        ]
        [ svg [ SAttr.class "vote-poll-select-cell-svg-no", SAttr.width "20", SAttr.height "20", SAttr.viewBox "0 0 20 20" ]
            [ line [ SAttr.x1 "4", SAttr.y1 "4", SAttr.x2 "16", SAttr.y2 "16" ] []
            , line [ SAttr.x1 "4", SAttr.y1 "16", SAttr.x2 "16", SAttr.y2 "4" ] []
            ]
        ]


viewCellIfNeeded : Bool -> Bool -> String -> Msg -> Translation -> Html Msg
viewCellIfNeeded changed transparent tooltip toggleMsg translation =
    div
        [ class <| "vote-poll-select-cell vote-poll-select-cell-ifneeded" ++ changedToClass changed ++ transparentToClass transparent
        , onClick toggleMsg
        , title <| fixTooltip tooltip translation.vote.ifNeeded
        ]
        [ svg [ SAttr.class "vote-poll-select-cell-svg-ifneeded", SAttr.width "20", SAttr.height "20", SAttr.viewBox "0 0 20 20" ]
            [ circle [ SAttr.cx "10", SAttr.cy "10", SAttr.r "7" ] []
            ]
        ]


viewAddedVoteRow : Poll -> Int -> AddedPersonRow -> Translation -> Html Msg
viewAddedVoteRow poll addedVoteIndex addedPersonRow translation =
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
                translation.vote.enterName

            else
                translation.vote.newPerson

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
            pollOptionIds poll

        changeMessage optionId selectedOption =
            if changed then
                SetAddedPersonRowOption poll.pollId addedVoteIndex (OptionId optionId) selectedOption

            else
                NoOp

        optionToCell (OptionId id) =
            case Maybe.withDefault No <| Dict.get id addedPersonRow.selectedOptions of
                Yes ->
                    viewCellYes changed (not changed) addedPersonRow.name (changeMessage id IfNeeded) translation

                No ->
                    viewCellNo changed (not changed) addedPersonRow.name (changeMessage id Yes) translation

                IfNeeded ->
                    viewCellIfNeeded changed (not changed) addedPersonRow.name (changeMessage id No) translation

        selectCells =
            List.map (\id -> td [] [ optionToCell id ]) itemIds

        editCell =
            td [ class "vote-poll-edit-cell" ]
                [ a
                    [ class "vote-poll-edit-link"
                    , onClick (DeleteAddedPersonRow poll.pollId addedVoteIndex)
                    , title translation.vote.rowActionDeleteTitle
                    ]
                    [ text translation.vote.rowActionDelete ]
                ]
    in
    tr [ class <| "vote-poll-row vote-poll-row-added" ++ editableToClass changed ]
        (td [ class "vote-poll-name-cell" ] [ nameInput ] :: (selectCells ++ [ editCell ]))


viewExistingVoteRow : Poll -> PersonRow -> ChangesInPersonRow -> Bool -> Bool -> Translation -> Html Msg
viewExistingVoteRow poll personRow changesInPersonRow deleted editable translation =
    let
        personId =
            personRow.personId

        nameToDisplay =
            Maybe.withDefault personRow.name changesInPersonRow.changedName

        nameInput =
            input
                [ type_ "text"
                , value nameToDisplay
                , class <| "vote-poll-existing-name-input" ++ editableToClass editable
                , onInput <| SetExistingPersonRowName poll.pollId personRow.personId
                , placeholder personRow.name
                , disabled <| deleted || not editable
                ]
                []

        nameCell =
            td []
                [ div [ class "vote-poll-name-cell-existing" ]
                    [ if editable then
                        button
                            [ class "vote-poll-name-cell-button"
                            , title translation.vote.revertRowButtonTitle
                            , onClick <| MakePersonRowNotEditable poll.pollId personId
                            ]
                            [ text "↶" ]

                      else
                        button
                            [ class "vote-poll-name-cell-button"
                            , title translation.vote.editRowButtonTitle
                            , onClick <| MakePersonRowEditable poll.pollId personId
                            ]
                            [ text "✎" ]
                    , div [ class "vote-poll-name-cell-name" ] [ nameInput ]
                    ]
                ]

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

                changeMessage selectedOption =
                    if editable then
                        SetExistingPersonRowOption poll.pollId personId optionId selectedOption

                    else
                        NoOp
            in
            case actual of
                Yes ->
                    viewCellYes changed False nameToDisplay (changeMessage IfNeeded) translation

                No ->
                    viewCellNo changed False nameToDisplay (changeMessage Yes) translation

                IfNeeded ->
                    viewCellIfNeeded changed False nameToDisplay (changeMessage No) translation

        optionCells =
            if deleted then
                [ td [ colspan <| List.length allIds ]
                    [ div [ class "vote-poll-select-cell vote-poll-deleted-cell" ]
                        [ text translation.vote.rowForDeletion ]
                    ]
                ]

            else
                List.map (\id -> td [] [ optionCell id ]) allIds

        editCell =
            if deleted then
                td [ class <| "vote-poll-edit-cell" ++ invisibleToClass (not editable) ]
                    [ a [ class "vote-poll-edit-link", onClick (UndeleteExistingPersonRow poll.pollId personId) ]
                        [ text translation.vote.rowActionRevert ]
                    ]

            else
                td [ class <| "vote-poll-edit-cell" ++ invisibleToClass (not editable) ]
                    [ a
                        [ class "vote-poll-edit-link"
                        , onClick (DeleteExistingPersonRow poll.pollId personId)
                        , title translation.vote.rowActionDeleteTitle
                        ]
                        [ text translation.vote.rowActionDelete ]
                    ]
    in
    tr [ class <| "vote-poll-row vote-poll-row-existing" ++ editableToClass editable ]
        ((nameCell :: optionCells) ++ [ editCell ])


viewAddNewVoteCell : ChangesInPoll -> Translation -> Html Msg
viewAddNewVoteCell changes translation =
    let
        allNamesFilled =
            List.all (\a -> not <| String.isEmpty a.name) changes.addedPersonRows

        ( hasFilled, hasEmpty ) =
            List.foldl (\c ( f, e ) -> ( f || (not <| String.isEmpty c.name), e || String.isEmpty c.name )) ( False, False ) changes.addedPersonRows

        link =
            if allNamesFilled then
                a
                    [ class "vote-poll-edit-link"
                    , onClick AddAnotherPersonRow
                    , title translation.vote.addRowTitle
                    ]
                    [ text translation.vote.addRow
                    ]

            else if hasFilled && hasEmpty then
                a
                    [ class "vote-poll-edit-link"
                    , onClick DeleteAllEmptyPersonRows
                    , title translation.vote.clearEmptyRowsTitle
                    ]
                    [ text translation.vote.clearEmptyRows
                    ]

            else
                span [ class "vote-poll-edit-link invisible" ] [ text "()" ]
    in
    td [ class "vote-poll-edit-cell" ]
        [ link
        ]


viewSubmitRow : ViewModel -> Html Msg
viewSubmitRow viewModel =
    let
        { isValidVotingState, hasChangesInVotes } =
            viewModel

        enabled =
            isValidVotingState && hasChangesInVotes
    in
    div [ class "vote-poll-center-outer" ]
        [ div [ class "vote-poll-center" ]
            [ div [ class "submit-row vote-poll-preferred-width" ]
                [ button [ class "submit-button common-button colors-edit", disabled <| not enabled, onClick SaveChanges ]
                    [ text viewModel.translation.common.saveChanges ]
                ]
            ]
        ]
