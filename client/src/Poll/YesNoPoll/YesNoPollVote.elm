module Poll.YesNoPoll.YesNoPollVote exposing (..)

import Data.CandidateId exposing (CandidateId, candidateIdInt)
import Data.PollRows exposing (VoterRow)
import Html exposing (Html, text)
import Poll.PollCommon exposing (PollOptionInfo)
import Poll.YesNoPoll.YesNoPollData exposing (YesNoOption)
import Translations.Translation exposing (Translation)


type YesNoPollVoteMsg
    = NoOp


type alias ViewConfig outerMsg =
    { outerMessage : YesNoPollVoteMsg -> outerMsg
    , translation : Translation
    }


yesNoPollVoteOptionView : PollOptionInfo YesNoOption -> ViewConfig a -> Html a
yesNoPollVoteOptionView pollOptionInfo viewConfig =
    text ""
