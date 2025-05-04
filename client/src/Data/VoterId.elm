module Data.VoterId exposing (VoterId(..), voterIdInt)


type VoterId
    = VoterId Int


voterIdInt : VoterId -> Int
voterIdInt (VoterId id) =
    id
