module Vote.VoteView exposing (view)

import Data.DataModel exposing (..)
import Dict exposing (..)
import Html exposing (Html, a, b, br, button, div, h1, h2, input, label, li, ol, option, p, select, span, table, td, text, th, tr)
import Html.Attributes exposing (class, colspan, disabled, href, min, placeholder, selected, tabindex, title, type_, value)
import Html.Events exposing (on, onClick, onInput, onMouseEnter, onMouseLeave)
import SDate.SDate exposing (..)
import Set exposing (..)
import Svg exposing (circle, line, svg)
import Svg.Attributes as SAttr
import Vote.VoteModel exposing (..)


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

        viewForPoll pollIndex poll =
            viewPoll pollIndex poll (changesForPoll poll.pollId) (stateForPoll poll.pollId)
    in
    div [ class "vote-project" ]
        [ div [ class "vote-poll-center-outer" ]
            [ div [ class "vote-poll-center" ]
                [ h1 [ class "vote-project-title vote-poll-preferred-width" ]
                    [ text <| Maybe.withDefault "(nepojmenovaný projekt)" project.title
                    ]
                , legend
                ]
            ]
        , div [ class "vote-polls" ] (List.indexedMap viewForPoll project.polls)
        , viewSubmitRow project changes states
        ]


legend : Html Msg
legend =
    div [ class "vote-legend" ]
        [ table []
            [ tr []
                [ td [ class "vote-legend-text" ] [ text "Legenda: " ]
                , viewCellYes False False "" NoOp
                , td [ class "vote-legend-text" ] [ text "Ano " ]
                , viewCellIfNeeded False False "" NoOp
                , td [ class "vote-legend-text" ] [ text "V nouzi " ]
                , viewCellNo False False "" NoOp
                , td [ class "vote-legend-text" ] [ text "Ne " ]
                ]
            ]
        ]


viewPoll : Int -> Poll -> ChangesInPoll -> ViewState -> Html Msg
viewPoll pollIndex poll changes state =
    let
        emptyCell =
            td [] []

        headerRow =
            viewPollHeader poll state

        resultCells =
            viewPollResultCells poll changes state

        resultsRow =
            if pollIndex == 0 then
                tr [] ((viewAddNewVoteCell poll changes :: resultCells) ++ [ emptyCell ])

            else
                tr [] ((emptyCell :: resultCells) ++ [ emptyCell ])

        addedRow index addedVote =
            viewAddedVoteRow poll index addedVote

        addedVotesRows =
            List.indexedMap addedRow changes.addedPersonRows

        changesForPerson personRow =
            Maybe.withDefault emptyChangesInPersonRow <| Dict.get (personIdInt personRow.personId) changes.changesInPersonRows

        isToBeDeleted personRow =
            Set.member (personIdInt personRow.personId) changes.deletedPersonRows

        isEditable personRow =
            Set.member (personIdInt personRow.personId) state.editableExistingRows

        existingVoteRow personRow =
            viewExistingVoteRow poll personRow (changesForPerson personRow) (isToBeDeleted personRow) (isEditable personRow)

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
                [ h2 [ class "vote-poll-title vote-poll-preferred-width" ] [ text <| Maybe.withDefault (String.concat [ "Hlasování ", String.fromInt <| pollIndex + 1 ]) poll.title ]
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
            th []
                [ div [ class "vote-poll-header-cell" ]
                    [ div [ class "vote-poll-day-in-week" ] [ text <| weekDayToString dayInWeek ]
                    , text dateString
                    ]
                ]

        dateCell { optionId, value } =
            dateTupleCell (weekDay value) (dateToString <| dayToTuple value)

        dateHeader items =
            tr [] ([ th [] [] ] ++ List.map dateCell items)

        genericCell item =
            th []
                [ div [ class "vote-poll-header-cell vote-poll-header-cell-generic" ] [ text item.value ]
                ]

        genericHeader items =
            tr [] ([ th [] [] ] ++ List.map genericCell items ++ [ th [] [] ])
    in
    case poll.pollInfo of
        DatePollInfo { items } ->
            dateHeader items

        GenericPollInfo { items } ->
            genericHeader items


viewPollResultCells : Poll -> ChangesInPoll -> ViewState -> List (Html Msg)
viewPollResultCells poll changesInPoll state =
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


changedToClass changed =
    if changed then
        " changed"

    else
        ""


editableToClass editable =
    if editable then
        " editable"

    else
        ""


invisibleToClass invisible =
    if invisible then
        " invisible"

    else
        ""


transparentToClass transparent =
    if transparent then
        " transparent"

    else
        ""


fixTooltip info state =
    if String.isEmpty <| String.trim info then
        state

    else
        info ++ ": " ++ state


viewCellYes : Bool -> Bool -> String -> Msg -> Html Msg
viewCellYes changed transparent tooltip toggleMsg =
    div
        [ class <| "vote-poll-select-cell vote-poll-select-cell-yes" ++ changedToClass changed ++ transparentToClass transparent
        , onClick toggleMsg
        , title <| fixTooltip tooltip "Ano"
        ]
        [ svg [ SAttr.class "vote-poll-select-cell-svg-yes", SAttr.width "20", SAttr.height "20", SAttr.viewBox "0 0 20 20" ]
            [ circle [ SAttr.cx "10", SAttr.cy "10", SAttr.r "7" ] []
            ]
        ]


viewCellNo : Bool -> Bool -> String -> Msg -> Html Msg
viewCellNo changed transparent tooltip toggleMsg =
    div
        [ class <| "vote-poll-select-cell vote-poll-select-cell-no" ++ changedToClass changed ++ transparentToClass transparent
        , onClick toggleMsg
        , title <| fixTooltip tooltip "Ne"
        ]
        [ svg [ SAttr.class "vote-poll-select-cell-svg-no", SAttr.width "20", SAttr.height "20", SAttr.viewBox "0 0 20 20" ]
            [ line [ SAttr.x1 "4", SAttr.y1 "4", SAttr.x2 "16", SAttr.y2 "16" ] []
            , line [ SAttr.x1 "4", SAttr.y1 "16", SAttr.x2 "16", SAttr.y2 "4" ] []
            ]
        ]


viewCellIfNeeded : Bool -> Bool -> String -> Msg -> Html Msg
viewCellIfNeeded changed transparent tooltip toggleMsg =
    div
        [ class <| "vote-poll-select-cell vote-poll-select-cell-ifneeded" ++ changedToClass changed ++ transparentToClass transparent
        , onClick toggleMsg
        , title <| fixTooltip tooltip "V nouzi"
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
                "(nový hlasující)"

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

        changeMessage optionId selectedOption =
            if changed then
                SetAddedPersonRowOption poll.pollId addedVoteIndex (OptionId optionId) selectedOption

            else
                NoOp

        optionToCell (OptionId id) =
            case Maybe.withDefault No <| Dict.get id addedPersonRow.selectedOptions of
                Yes ->
                    viewCellYes changed (not changed) addedPersonRow.name (changeMessage id IfNeeded)

                No ->
                    viewCellNo changed (not changed) addedPersonRow.name (changeMessage id Yes)

                IfNeeded ->
                    viewCellIfNeeded changed (not changed) addedPersonRow.name (changeMessage id No)

        selectCells =
            List.map (\id -> td [] [ optionToCell id ]) itemIds

        editCell =
            td [ class "vote-poll-edit-cell" ]
                [ a
                    [ class "vote-poll-edit-link"
                    , onClick (DeleteAddedPersonRow poll.pollId addedVoteIndex)
                    , title "Smaž řádek pouze v tomto hlasování"
                    ]
                    [ text "Smaž" ]
                ]
    in
    tr [ class <| "vote-poll-row vote-poll-row-added" ++ editableToClass changed ]
        (td [ class "vote-poll-name-cell" ] [ nameInput ] :: (selectCells ++ [ editCell ]))


viewExistingVoteRow : Poll -> PersonRow -> ChangesInPersonRow -> Bool -> Bool -> Html Msg
viewExistingVoteRow poll personRow changesInPersonRow deleted editable =
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
                            , title "Zapomeň a zruš úpravy v tomto řádku."
                            , onClick <| MakePersonRowNotEditable poll.pollId personId
                            ]
                            [ text "↶" ]

                      else
                        button
                            [ class "vote-poll-name-cell-button"
                            , title "Uprav tento řádek. Pamatujte, prosím, že měnit hlasování ostatních bez dovolení není hezké!"
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
                    viewCellYes changed False nameToDisplay <| changeMessage IfNeeded

                No ->
                    viewCellNo changed False nameToDisplay <| changeMessage Yes

                IfNeeded ->
                    viewCellIfNeeded changed False nameToDisplay <| changeMessage No

        optionCells =
            if deleted then
                [ td [ colspan <| List.length allIds ]
                    [ div [ class "vote-poll-select-cell vote-poll-deleted-cell" ]
                        [ text "Ke smazání" ]
                    ]
                ]

            else
                List.map (\id -> td [] [ optionCell id ]) allIds

        editCell =
            if deleted then
                td [ class <| "vote-poll-edit-cell" ++ invisibleToClass (not editable) ]
                    [ a [ class "vote-poll-edit-link", onClick (UndeleteExistingPersonRow poll.pollId personId) ]
                        [ text "Vrať" ]
                    ]

            else
                td [ class <| "vote-poll-edit-cell" ++ invisibleToClass (not editable) ]
                    [ a
                        [ class "vote-poll-edit-link"
                        , onClick (DeleteExistingPersonRow poll.pollId personId)
                        , title "Smaž řádek pouze v tomto hlasování"
                        ]
                        [ text "Smaž" ]
                    ]
    in
    tr [ class <| "vote-poll-row vote-poll-row-existing" ++ editableToClass editable ]
        ((nameCell :: optionCells) ++ [ editCell ])


viewAddNewVoteCell : Poll -> ChangesInPoll -> Html Msg
viewAddNewVoteCell poll changes =
    let
        allNamesFilled =
            List.all (\a -> not <| String.isEmpty a.name) changes.addedPersonRows

        ( hasFilled, hasEmpty ) =
            List.foldl (\c ( f, e ) -> ( f || (not <| String.isEmpty c.name), e || String.isEmpty c.name )) ( False, False ) changes.addedPersonRows

        link =
            if allNamesFilled then
                a
                    [ class "vote-poll-edit-link"
                    , onClick (AddAnotherPersonRow poll.pollId)
                    , title "Přidej nového hlasujícího do všech hlasování"
                    ]
                    [ text "+ Přidej člověka"
                    ]

            else if hasFilled && hasEmpty then
                a
                    [ class "vote-poll-edit-link"
                    , onClick DeleteAllEmptyPersonRows
                    , title "Odebrat řádky s nevyplněným jménem ze všech hlasování"
                    ]
                    [ text "Odeber nevyplněné"
                    ]

            else
                span [ class "vote-poll-edit-link invisible" ] [ text "()" ]
    in
    td [ class "vote-poll-edit-cell" ]
        [ link
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
