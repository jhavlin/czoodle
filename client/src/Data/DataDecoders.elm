module Data.DataDecoders exposing (decodePollInfo)

import Candidate.DateCandidate.DateCandidateEncoding exposing (decodeDateCandidateItem)
import Candidate.TextCandidate.TextCandidateEncoding exposing (decodeTextCandidateItem)
import Common.CommonUtils exposing (stringToMaybe)
import Data.DataModel
    exposing
        ( CandidatesInfo(..)
        , PollId(..)
        , PollInfo
        , VoterId(..)
        )
import Json.Decode as D
import Data.DataModel exposing (VotesInfo)


decodeCandidatesInfo : D.Decoder CandidatesInfo
decodeCandidatesInfo =
    let
        dateCandidatesInfoDecoder =
            D.map DateCandidatesInfo <|
                D.field "items" (D.list decodeDateCandidateItem)

        textCandidatesInfoDecoder =
            D.map TextCandidatesInfo <|
                D.field "items" (D.list decodeTextCandidateItem)

        choose type_ =
            case type_ of
                "date" ->
                    dateCandidatesInfoDecoder

                "text" ->
                    textCandidatesInfoDecoder

                _ ->
                    D.fail <| "Invalid 'candidates' type " ++ type_
    in
    D.andThen choose <| D.field "type" D.string


decodeVotesInfo : D.Decoder VotesInfo
decodeVotesInfo =
    let
        yesNoVotesInfoDecoder =
            D.map DateCandidatesInfo <|
                D.field "items" (D.list decodeDateCandidateItem)

        choose type_ =
            case type_ of
                "yesNo" ->
                    dateCandidatesInfoDecoder

                _ ->
                    D.fail <| "Invalid 'candidates' type " ++ type_
    in
    D.andThen choose <| D.field "type" D.string



{-



   decodePollInfo : D.Decoder PollInfo
   decodePollInfo =
       let
           datePollInfoDecoder =
               D.map (\l -> DatePollInfo { items = l }) <|
                   D.field "items" (D.list decodeDateCandidateItem)

           genericPollInfoDecoder =
               D.map (\l -> GenericPollInfo { items = l }) <|
                   D.field "items" (D.list decodeTextCandidateItem)

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



   decodePersonRow : D.Decoder PersonRow
   decodePersonRow =
       let
           pairsDecoder : D.Decoder (List ( String, SelectedOption ))
           pairsDecoder =
               D.keyValuePairs decodeSelectedOption

           foldFn : ( String, SelectedOption ) -> Maybe (Dict Int SelectedOption) -> Maybe (Dict Int SelectedOption)
           foldFn ( strKey, value ) acc =
               Maybe.map2 (\int dict -> Dict.insert int value dict) (String.toInt strKey) acc

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
       D.map6 Poll
           (D.map PollId <| D.field "id" D.int)
           (D.map stringToMaybe <| D.field "title" D.string)
           (D.maybe <| D.field "description" D.string)
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
               D.map5 Project
                   (D.map stringToMaybe (D.field "title" <| D.string))
                   (D.field "polls" <| D.list decodePoll)
                   (D.field "lastPollId" D.int)
                   (D.field "comments" <| D.list decodeComment)
                   (D.field "lastCommentId" D.int)
       in
       D.decodeValue projectDecoder json

-}
