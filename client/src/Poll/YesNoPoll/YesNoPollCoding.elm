module Poll.YesNoPoll.YesNoPollCoding exposing (..)

import Data.Comments exposing (RowComment(..), VoteComment(..), rowCommentToString, voteCommentToString)
import Data.PollRows exposing (PollRows, VoteWithComment, VoterRow, VoterVotes)
import Dict exposing (Dict)
import Json.Decode as D
import Json.Encode as E
import Poll.YesNoPoll.YesNoPollData exposing (YesNoOption(..), YesNoPollSettings, yesNoOptionFromString, yesNoOptionToString)



{- Convert dictionary with string keys to dictionary with int keys,
   it is needed because objects in JSON have always string keys.
-}


stringKeyedDictToIntKeyedDict : Dict String v -> Dict Int v
stringKeyedDictToIntKeyedDict f =
    let
        listWithStringKey : List ( String, v )
        listWithStringKey =
            Dict.toList f

        listWithIntKey : List ( Int, v )
        listWithIntKey =
            List.filterMap
                (\( k, value ) -> String.toInt k |> Maybe.map (\ki -> ( ki, value )))
                listWithStringKey
    in
    Dict.fromList listWithIntKey



{- Convert dictionary with int keys to a list of key-value pair, where the
   key is converted to string, which is needed when encoding the dictionary
   to JSON.
-}


intKeyedDictToStringValuePairs : Dict Int v -> List ( String, v )
intKeyedDictToStringValuePairs dict =
    let
        intVotePairs : List ( Int, v )
        intVotePairs =
            Dict.toList dict
    in
    List.map (\( k, v ) -> ( String.fromInt k, v )) intVotePairs



{- Map values in a list of key-value pairs. -}


mapPairListSecond : (a -> b) -> List ( k, a ) -> List ( k, b )
mapPairListSecond fn list =
    List.map (\( k, v ) -> ( k, fn v )) list


decodeYesNoOption : D.Decoder YesNoOption
decodeYesNoOption =
    D.map yesNoOptionFromString D.string


encodeYesNoOption : YesNoOption -> E.Value
encodeYesNoOption o =
    E.string <| yesNoOptionToString o


decodeYesNoPollSettings : D.Decoder YesNoPollSettings
decodeYesNoPollSettings =
    D.map2 YesNoPollSettings
        (D.field "allowIfNeeded" D.bool)
        (D.field "allowMaybe" D.bool)


encodeYesNoPollSettings : YesNoPollSettings -> E.Value
encodeYesNoPollSettings settings =
    E.object
        [ ( "allowIfNeeded", E.bool settings.allowIfNeeded )
        , ( "allowMaybe", E.bool settings.allowMaybe )
        ]


decodeYesNoVote : D.Decoder (VoteWithComment YesNoOption)
decodeYesNoVote =
    {- TODO make comment optional, possibly also option -}
    D.map2 (\v c -> { vote = v, comment = VoteComment c })
        (D.field "v" decodeYesNoOption)
        (D.field "c" D.string)


encodeYesNoVote : VoteWithComment YesNoOption -> E.Value
encodeYesNoVote { vote, comment } =
    E.object
        [ ( "v", encodeYesNoOption vote )
        , ( "c", E.string <| voteCommentToString comment )
        ]


decodeOneVoterVotes : D.Decoder (VoterVotes YesNoOption)
decodeOneVoterVotes =
    D.map stringKeyedDictToIntKeyedDict <| D.dict decodeYesNoVote


encodeOneVoterVotes : VoterVotes YesNoOption -> E.Value
encodeOneVoterVotes dict =
    let
        stringOptionPairs : List ( String, VoteWithComment YesNoOption )
        stringOptionPairs =
            intKeyedDictToStringValuePairs dict

        stringValuePairs : List ( String, E.Value )
        stringValuePairs =
            mapPairListSecond encodeYesNoVote stringOptionPairs
    in
    E.object stringValuePairs


decodeOneVoterVotesAndComment : D.Decoder (VoterRow YesNoOption)
decodeOneVoterVotesAndComment =
    {- TODO make comment optional -}
    D.map2 (\v c -> { voterVotes = v, voterComment = RowComment c })
        (D.field "votes" decodeOneVoterVotes)
        (D.field "comment" D.string)


encodeOneVoterVotesAndComment : VoterRow YesNoOption -> E.Value
encodeOneVoterVotesAndComment r =
    E.object
        [ ( "votes", encodeOneVoterVotes r.voterVotes )
        , ( "comment", E.string <| rowCommentToString r.voterComment )
        ]


decodeYesNoVotesInfo : D.Decoder { settings : YesNoPollSettings, votes : PollRows YesNoOption }
decodeYesNoVotesInfo =
    let
        decodeVotes : D.Decoder (PollRows YesNoOption)
        decodeVotes =
            D.map stringKeyedDictToIntKeyedDict <| D.dict decodeOneVoterVotesAndComment
    in
    D.map2 (\settings votes -> { settings = settings, votes = votes })
        (D.field "settings" decodeYesNoPollSettings)
        (D.field "votes" decodeVotes)


encodeYesNoVotesInfo : { settings : YesNoPollSettings, votes : PollRows YesNoOption } -> E.Value
encodeYesNoVotesInfo { settings, votes } =
    let
        stringToRowPairs : List ( String, VoterRow YesNoOption )
        stringToRowPairs =
            intKeyedDictToStringValuePairs votes

        encodedVotes : List ( String, E.Value )
        encodedVotes =
            mapPairListSecond encodeOneVoterVotesAndComment stringToRowPairs
    in
    E.object
        [ ( "settings", encodeYesNoPollSettings settings )
        , ( "votes", E.object <| encodedVotes )
        ]
