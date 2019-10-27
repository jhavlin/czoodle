port module Data.DataModel exposing (AddedComment, AddedPersonRow, ChangesInPersonRow, ChangesInPoll, ChangesInProject, Comment, CommentId(..), DateOptionItem, DayTuple, GenericOptionItem, Keys, OptionId(..), PersonId(..), PersonRow, Poll, PollId(..), PollInfo(..), Project, SelectedOption(..), commentIdInt, optionIdInt, personIdInt, pollIdInt)

import Dict exposing (..)
import SDate.SDate exposing (..)
import Set exposing (..)



-----------------------------------------------------------
---- Types
-----------------------------------------------------------


type alias Keys =
    { projectKey : String
    , secretKey : String
    }


type alias DayTuple =
    ( Int, Int, Int )


type SelectedOption
    = Yes
    | No
    | IfNeeded


type PollId
    = PollId Int


type PersonId
    = PersonId Int


type OptionId
    = OptionId Int


type alias DateOptionItem =
    { optionId : OptionId
    , value : SDay
    }


type alias GenericOptionItem =
    { optionId : OptionId
    , value : String
    }


type CommentId
    = CommentId Int


type alias Comment =
    { commentId : CommentId
    , text : String
    }


type alias PersonRow =
    { personId : PersonId
    , name : String
    , selectedOptions : Dict Int SelectedOption
    }


type PollInfo
    = DatePollInfo { items : List DateOptionItem }
    | GenericPollInfo { items : List GenericOptionItem }


type alias Poll =
    { pollId : PollId
    , title : Maybe String
    , description : Maybe String
    , pollInfo : PollInfo
    , personRows : List PersonRow
    , lastPersonId : Int
    }


type alias Project =
    { title : Maybe String
    , polls : List Poll
    , lastPollId : Int
    , comments : List Comment
    , lastCommentId : Int
    }


type alias ChangesInProject =
    { changesInPolls : Dict Int ChangesInPoll
    , addedComments : List AddedComment
    }


type alias AddedComment =
    { text : String
    }


type alias ChangesInPoll =
    { changesInPersonRows : Dict Int ChangesInPersonRow
    , addedPersonRows : List AddedPersonRow
    , deletedPersonRows : Set Int
    }


type alias ChangesInPersonRow =
    { changedName : Maybe String
    , changedOptions : Dict Int SelectedOption
    }


type alias AddedPersonRow =
    { name : String
    , selectedOptions : Dict Int SelectedOption
    }



-----------------------------------------------------------
---- Functions
-----------------------------------------------------------


pollIdInt : PollId -> Int
pollIdInt (PollId id) =
    id


personIdInt : PersonId -> Int
personIdInt (PersonId id) =
    id


commentIdInt : CommentId -> Int
commentIdInt (CommentId id) =
    id


optionIdInt : OptionId -> Int
optionIdInt (OptionId id) =
    id
