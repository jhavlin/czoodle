module Poll.PollKinds exposing
    ( KindOfPollInnerMsg
    , KindOfVotesInfo
    , KindOfVoterRow
    , isEdited
    , encodeVotesInfo
    , decodeVotesInfo
    , defaultVotesInfo
    )

import Data.PollRows exposing (VoterRow)
import Poll.YesNoPoll.YesNoPollData as YesNoPollData exposing (YesNoOption)
import Poll.YesNoPoll.YesNoPollVote exposing (YesNoPollVoteMsg)
import Poll.YesNoPoll.YesNoPollData exposing (YesNoPollSettings)
import Data.PollRows exposing (PollRows)
import Json.Encode as E
import Json.Decode as D
import Poll.YesNoPoll.YesNoPollCoding exposing (decodeYesNoVotesInfo)
import Poll.YesNoPoll.YesNoPollCoding exposing (encodeYesNoVotesInfo)
import Poll.YesNoPoll.YesNoPollData exposing (defaultYesNoPollSettings)
import Dict


type KindOfPollInnerMsg
    = YesNoPollInnerMsg YesNoPollVoteMsg


type KindOfVoterRow
    = YesNoVoterRow (VoterRow YesNoOption)


type KindOfVotesInfo
    = YesNoVotesInfo
        { settings : YesNoPollSettings
        , votes : PollRows YesNoOption
        }

isEdited : KindOfVoterRow -> Bool
isEdited kindOfVoterRow =
    case kindOfVoterRow of
        YesNoVoterRow voterRow ->
            YesNoPollData.isEdited voterRow

decodeVotesInfo : D.Decoder KindOfVotesInfo
decodeVotesInfo =
    let
        choose type_ =
            case type_ of
                "yesNo" ->
                    D.map YesNoVotesInfo decodeYesNoVotesInfo

                _ ->
                    D.fail <| "Invalid 'candidates' type " ++ type_
    in
    D.andThen choose <| D.field "type" D.string


encodeVotesInfo : KindOfVotesInfo -> E.Value
encodeVotesInfo votesInfo =
    case votesInfo of
        YesNoVotesInfo info ->
            encodeYesNoVotesInfo ( "type", E.string "yesNo" ) info


defaultVotesInfo : KindOfVotesInfo
defaultVotesInfo = YesNoVotesInfo { settings = defaultYesNoPollSettings, votes = Dict.empty }
