module Poll.YesNoPoll.YesNoPollData exposing (..)

import Data.Comments exposing (RowComment(..), isVoteCommentSet, rowCommentToString)
import Data.PollRows exposing (ChangedVoterRow, RowChange(..), VoterRow, VoterRowStatus(..))
import Dict


type YesNoOption
    = Yes
    | No
    | IfNeeded
    | Maybe
    | Unset


type alias YesNoPollSettings =
    { allowIfNeeded : Bool
    , allowMaybe : Bool
    }


yesNoOptionToString : YesNoOption -> String
yesNoOptionToString yesNoOption =
    case yesNoOption of
        Yes ->
            "yes"

        No ->
            "no"

        IfNeeded ->
            "ifNeeded"

        Maybe ->
            "maybe"

        Unset ->
            "unset"


yesNoOptionFromString : String -> YesNoOption
yesNoOptionFromString string =
    case string of
        "yes" ->
            Yes

        "no" ->
            No

        "ifNeeded" ->
            IfNeeded

        "maybe" ->
            Maybe

        _ ->
            Unset


defaultYesNoPollSettings : YesNoPollSettings
defaultYesNoPollSettings =
    { allowIfNeeded = True
    , allowMaybe = False
    }


isEdited : VoterRow YesNoOption -> Bool
isEdited voterRow =
    (not <| String.isEmpty <| String.trim (rowCommentToString voterRow.rowComment))
        || (Dict.values voterRow.voterVotes |> List.any (\o -> isVoteCommentSet o.comment || o.vote /= No))



{- Normalize changes, TODO -}


normalizeChanges : VoterRow YesNoOption -> ChangedVoterRow YesNoOption -> Maybe (ChangedVoterRow YesNoOption)
normalizeChanges row changes =
    Just changes


getEmptyVoterRow : VoterRow YesNoOption
getEmptyVoterRow =
    { voterVotes = Dict.empty, rowComment = RowComment "", status = Valid }


getEmptyChangesInRow : ChangedVoterRow YesNoOption
getEmptyChangesInRow =
    { changedVoterComment = Nothing, rowChange = VotesChanged Dict.empty }
