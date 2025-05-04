module Poll.YesNoPoll.YesNoPollEncoding exposing (..)

import Data.Comments exposing (RowComment(..), VoteComment(..))
import Data.PollRows exposing (PollRows, VoteWithComment, VoterRow, VoterVotes)
import Dict exposing (Dict)
import Json.Decode as D
import Poll.YesNoPoll.YesNoPollData exposing (YesNoOption(..), YesNoPollSettings)


stringKeyedDictToIntKeyedDict : Dict String v -> Dict Int v
stringKeyedDictToIntKeyedDict f =
    let
        listWithStringKey : List ((String, v))
        listWithStringKey = Dict.toList f

        listWithIntKey : List ((Int, v))
        
    in


decodeYesNoOption : D.Decoder YesNoOption
decodeYesNoOption =
    let
        convert s =
            case s of
                "y" ->
                    Yes

                "n" ->
                    No

                "i" ->
                    IfNeeded

                "m" ->
                    Maybe

                _ ->
                    Unset
    in
    D.map convert D.string


decodeYesNoPollSettings : D.Decoder YesNoPollSettings
decodeYesNoPollSettings =
    D.map2 YesNoPollSettings
        (D.field "allowIfNeeded" D.bool)
        (D.field "allowMaybe" D.bool)


decodeYesNoVote : D.Decoder (VoteWithComment YesNoOption)
decodeYesNoVote =
    {- TODO make comment optional, possibly also option -}
    D.map2 (\v c -> { vote = v, comment = VoteComment c })
        (D.field "v" decodeYesNoOption)
        (D.field "c" D.string)


decodeOneVoterVotes : D.Decoder (VoterVotes YesNoOption)
decodeOneVoterVotes =
    D.map stringKeyedDictToIntKeyedDict <| D.dict decodeYesNoVote


decodeOneVoterVotesAndComment : D.Decoder (VoterRow YesNoOption)
decodeOneVoterVotesAndComment =
    D.map2 (\v c -> { voterVotes = v, voterComment = RowComment c })
        (D.field "votes" decodeOneVoterVotes)
        (D.field "comment" D.string)


decodeYesNoVotesInfo : D.Decoder { settings : YesNoPollSettings, votes : PollRows YesNoOption }
decodeYesNoVotesInfo =
    let
        {- Decode one row of votes, i.e. votes in a poll from one voter, mapping from candidate id to -}
        decodeVotes : D.Decoder (PollRows YesNoOption)
        decodeVotes =
            D.map stringKeyedDictToIntKeyedDict <| D.dict decodeOneVoterVotesAndComment
    in
    D.map2 (\settings votes -> { settings = settings, votes = votes })
        (D.field "settings" decodeYesNoPollSettings)
        (D.field "votes" decodeVotes)
