module Common.CommonModel exposing
    ( CalendarStateModel
    , DayTuple
    )

import SDate.SDate exposing (SDay, SMonth)


type alias DayTuple =
    ( Int, Int, Int )


type alias CalendarStateModel =
    { month : SMonth
    , highlightedDay : Maybe DayTuple
    , today : SDay
    }
