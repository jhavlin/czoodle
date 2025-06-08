module Data.Comments exposing
    ( RowComment(..)
    , VoteComment(..)
    , isRowCommentEmpty
    , isRowCommentSet
    , isVoteCommentEmpty
    , isVoteCommentSet
    , rowCommentToString
    , voteCommentToString
    )


type RowComment
    = RowComment String


type VoteComment
    = VoteComment String


rowCommentToString : RowComment -> String
rowCommentToString (RowComment comment) =
    comment


voteCommentToString : VoteComment -> String
voteCommentToString (VoteComment comment) =
    comment


isRowCommentEmpty : RowComment -> Bool
isRowCommentEmpty (RowComment comment) =
    String.isEmpty <| String.trim comment


isVoteCommentEmpty : VoteComment -> Bool
isVoteCommentEmpty (VoteComment comment) =
    String.isEmpty <| String.trim comment


isRowCommentSet : RowComment -> Bool
isRowCommentSet =
    not << isRowCommentEmpty


isVoteCommentSet : VoteComment -> Bool
isVoteCommentSet =
    not << isVoteCommentEmpty
