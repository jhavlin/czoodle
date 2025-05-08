module Candidate.TextCandidate.TextCandidateCoding exposing (..)

import Candidate.TextCandidate.TextCandidateData exposing (TextCandidateItem)
import Data.CandidateId exposing (CandidateId(..), candidateIdInt)
import Json.Decode as D
import Json.Encode as E


decodeTextCandidateItem : D.Decoder TextCandidateItem
decodeTextCandidateItem =
    D.map3 TextCandidateItem
        (D.map CandidateId <| D.field "id" D.int)
        (D.field "value" D.string)
        (D.map (Maybe.withDefault False) <| (D.maybe <| D.field "hidden" D.bool))


encodeTextCandidateItem : TextCandidateItem -> E.Value
encodeTextCandidateItem item =
    E.object
        ([ ( "id", E.int <| candidateIdInt item.candidateId )
         , ( "value", E.string item.value )
         ]
            ++ (if item.hidden then
                    [ ( "hidden", E.bool True ) ]

                else
                    []
               )
        )
