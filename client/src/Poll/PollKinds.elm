module Poll.PollKinds exposing
    ( KindOfChangedVoterRow
    , KindOfPollInnerMsg
    , KindOfVoterRow(..) -- TODO hide variants
    , KindOfVotesInfo(..) -- TODO hide variants
    , decodeVotesInfo
    , defaultVotesInfo
    , encodeVotesInfo
    , getEmptyVoterRow
    , getVoterRow
    , isEdited
    , normalizeChanges
    )

import Data.PollRows exposing (ChangedVoterRow, PollRows, VoterRow)
import Data.VoterId exposing (VoterId, voterIdInt)
import Dict
import Html.Attributes exposing (type_)
import Json.Decode as D
import Json.Encode as E
import Poll.YesNoPoll.YesNoPollCoding exposing (decodeYesNoVotesInfo, encodeYesNoVotesInfo)
import Poll.YesNoPoll.YesNoPollData as YesNoPollData exposing (YesNoOption, YesNoPollSettings, defaultYesNoPollSettings)
import Poll.YesNoPoll.YesNoPollVote exposing (YesNoPollVoteMsg)


type KindOfPollInnerMsg
    = YesNoPollInnerMsg YesNoPollVoteMsg


type KindOfVoterRow
    = YesNoVoterRow (VoterRow YesNoOption)


type KindOfChangedVoterRow
    = YesNoChangedVoterRow (ChangedVoterRow YesNoOption)


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
defaultVotesInfo =
    YesNoVotesInfo { settings = defaultYesNoPollSettings, votes = Dict.empty }


getVoterRow : KindOfVotesInfo -> VoterId -> Maybe KindOfVoterRow
getVoterRow votesInfo voterId =
    case votesInfo of
        YesNoVotesInfo { votes } ->
            Dict.get (voterIdInt voterId) votes |> Maybe.map YesNoVoterRow


getEmptyVoterRow : KindOfVotesInfo -> KindOfVoterRow
getEmptyVoterRow votesInfo =
    case votesInfo of
        YesNoVotesInfo _ ->
            YesNoVoterRow YesNoPollData.getEmptyVoterRow


getEmptyChangesInRow : KindOfVotesInfo -> KindOfChangedVoterRow
getEmptyChangesInRow votesInfo =
    case votesInfo of
        YesNoVotesInfo _ ->
            YesNoChangedVoterRow YesNoPollData.getEmptyChangesInRow



{-
   Normalize changes, i.e. keep only changes that actually differs from the
   current version of the data. If there are no changes, return value
   Nothing.

   TODO
-}


normalizeChanges : KindOfVoterRow -> KindOfChangedVoterRow -> Maybe KindOfChangedVoterRow
normalizeChanges voterRow changes =
    case ( voterRow, changes ) of
        ( YesNoVoterRow r, YesNoChangedVoterRow ch ) ->
            YesNoPollData.normalizeChanges r ch |> Maybe.map YesNoChangedVoterRow
