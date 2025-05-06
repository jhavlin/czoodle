module Data.Comments exposing (RowComment(..), VoteComment(..), rowCommentToString, voteCommentToString)


type RowComment
    = RowComment String


type VoteComment
    = VoteComment String


voteCommentToString : VoteComment -> String
voteCommentToString (VoteComment comment) =
    comment


rowCommentToString : RowComment -> String
rowCommentToString (RowComment comment) =
    comment
