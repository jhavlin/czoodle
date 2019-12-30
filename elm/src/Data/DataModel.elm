module Data.DataModel exposing
    ( Comment
    , CommentId(..)
    , DateOptionItem
    , GenericOptionItem
    , Keys
    , OptionId(..)
    , PersonId(..)
    , PersonRow
    , Poll
    , PollId(..)
    , PollInfo(..)
    , Project
    , SelectedOption(..)
    , commentIdInt
    , optionIdInt
    , personIdInt
    , pollIdInt
    )

import Dict exposing (Dict)
import SDate.SDate exposing (SDay)



-----------------------------------------------------------
---- Types
-----------------------------------------------------------


type alias Keys =
    { projectKey : String
    , secretKey : String
    }


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
    , hidden : Bool
    }


type alias GenericOptionItem =
    { optionId : OptionId
    , value : String
    , hidden : Bool
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
