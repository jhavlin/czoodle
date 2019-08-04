module SDate.SDate exposing
    ( SDay
    , SMonth
    , SYear
    , dayFromTuple
    , dayToTuple
    , daysInMonth
    , defaultDay
    , monthFromDay
    , monthFromTuple
    , monthToTuple
    , nextMonth
    , prevMonth
    , weekDay
    , weeksInMonth
    , yearFromInt
    )

import Array exposing (..)


type SYear
    = SYear Int


type SMonth
    = SMonth SYear Int


type SDay
    = SDay SMonth Int



-- First supported year, and the base year


minYear : Int
minYear =
    1900



-- Days in months - standard year


daysInMonthsInStandardYear : Array Int
daysInMonthsInStandardYear =
    Array.fromList [ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 ]



-- Days in months - learp year


daysInMonthsInLeapYear : Array Int
daysInMonthsInLeapYear =
    Array.fromList [ 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 ]



-- Create array with days before months from array with days in months


daysBeforeMonths : Array Int -> Array Int
daysBeforeMonths daysInMonths =
    let
        fn days ( sum, arr ) =
            ( sum + days, Array.push sum arr )

        ( _, sumsArray ) =
            Array.foldl fn ( 0, Array.empty ) daysInMonths
    in
    sumsArray



-- Days before months - standard year


daysBeforeMonthsInStandardYear : Array Int
daysBeforeMonthsInStandardYear =
    daysBeforeMonths daysInMonthsInStandardYear



-- Days before months - leap year


daysBeforeMonthsInLeapYear : Array Int
daysBeforeMonthsInLeapYear =
    daysBeforeMonths daysInMonthsInLeapYear



-- Array with days in months in a year


daysInMonthsInYear : Int -> Array Int
daysInMonthsInYear year =
    if isLeapYear year then
        daysInMonthsInLeapYear

    else
        daysInMonthsInStandardYear



-- Array with sum of days before months in a year


daysBeforeMonthsInYear : Int -> Array Int
daysBeforeMonthsInYear year =
    if isLeapYear year then
        daysBeforeMonthsInLeapYear

    else
        daysBeforeMonthsInStandardYear



-- Get year from an int (year number).


yearFromInt : Int -> Maybe SYear
yearFromInt year =
    if year >= minYear then
        Just (SYear year)

    else
        Nothing



-- Get month from two ints: year number, month number (1-based).


monthFromTuple : ( Int, Int ) -> Maybe SMonth
monthFromTuple ( year, month ) =
    let
        yearMaybe =
            yearFromInt year
    in
    Maybe.andThen (\sYear -> monthInYear sYear month) yearMaybe


monthFromDay : SDay -> SMonth
monthFromDay (SDay sMonth _) =
    sMonth


monthToTuple : SMonth -> ( Int, Int )
monthToTuple (SMonth (SYear year) month) =
    ( year, month )



-- Get day from three ints - year number, month number (1-based), day number (1-based).


dayFromTuple : ( Int, Int, Int ) -> Maybe SDay
dayFromTuple ( year, month, day ) =
    let
        makeDay m =
            if day > 0 && day <= daysInMonth m then
                Just (SDay m day)

            else
                Nothing

        monthMaybe =
            monthFromTuple ( year, month )
    in
    Maybe.andThen makeDay monthMaybe



-- Convert a day to tuple


dayToTuple : SDay -> ( Int, Int, Int )
dayToTuple (SDay (SMonth (SYear year) month) day) =
    ( year, month, day )



--  Get a month from year and mont number


monthInYear : SYear -> Int -> Maybe SMonth
monthInYear year month =
    if month < 1 || month > 12 then
        Nothing

    else
        Just (SMonth year month)



-- Get number of week of a date, 0 - Monday, 6 - Sunday


weekDay : SDay -> Int
weekDay sDay =
    let
        ( year, month, day ) =
            dayToTuple sDay

        wholeYears =
            year - minYear

        div4 =
            divisiblesInRange minYear year 4

        div100 =
            divisiblesInRange minYear year 100

        div400 =
            divisiblesInRange minYear year 400

        yearDays =
            (((wholeYears * 365) + div4) - div100) + div400

        monthDays =
            Maybe.withDefault 0 (Array.get (month - 1) <| daysBeforeMonthsInYear year)

        daysBetween =
            yearDays + monthDays + day - 1
    in
    remainderBy 7 daysBetween



-- Get count of integers that are within given range (start inclusive, end exclusive)
-- and that are divisible by given value


divisiblesInRange : Int -> Int -> Int -> Int
divisiblesInRange start end divisible =
    let
        rem =
            remainderBy divisible

        first =
            start + rem (divisible - rem start)

        last =
            end - rem end

        plus1Correction =
            if last < end then
                1

            else
                0
    in
    if first <= last then
        ((last - first) // divisible) + plus1Correction

    else
        0



-- Get number of days in given month


daysInMonth : SMonth -> Int
daysInMonth (SMonth (SYear year) month) =
    let
        res =
            Array.get (month - 1) <| daysInMonthsInYear year
    in
    Maybe.withDefault 0 res



-- Tell if given year is leap or not.


isLeapYear : Int -> Bool
isLeapYear year =
    remainderBy 4 year == 0 && (remainderBy 100 year /= 0 || remainderBy 400 year == 0)


nextMonth : SMonth -> SMonth
nextMonth (SMonth ((SYear year) as sYear) month) =
    if month == 12 then
        SMonth (SYear (year + 1)) 1

    else
        SMonth sYear (month + 1)


prevMonth : SMonth -> SMonth
prevMonth (SMonth ((SYear year) as sYear) month) =
    if month == 1 then
        SMonth (SYear (year - 1)) 12

    else
        SMonth sYear (month - 1)


prevDay : SDay -> SDay
prevDay (SDay sMonth day) =
    if day > 1 then
        SDay sMonth (day - 1)

    else
        let
            monthBefore =
                prevMonth sMonth
        in
        SDay monthBefore (daysInMonth monthBefore)


nextDay : SDay -> SDay
nextDay (SDay sMonth day) =
    if day < daysInMonth sMonth then
        SDay sMonth (day + 1)

    else
        SDay (nextMonth sMonth) 1



-- Get list (month) of lists (weeks) of days in month, including days just before and after the given
-- month. Suitable for building calendar UIs.


weeksInMonth : SMonth -> List (List SDay)
weeksInMonth sMonth =
    let
        firstDayOfMonth =
            SDay sMonth 1

        lastDayOfMonth =
            SDay sMonth <| daysInMonth sMonth

        firstWeekDay =
            weekDay firstDayOfMonth

        monthBefore =
            prevMonth sMonth

        firstDay =
            if firstWeekDay == 0 then
                firstDayOfMonth

            else
                SDay monthBefore (daysInMonth monthBefore - (firstWeekDay - 1))

        lastWeekDay =
            weekDay lastDayOfMonth

        monthAfter =
            nextMonth sMonth

        lastDay =
            if lastWeekDay == 6 then
                lastDayOfMonth

            else
                SDay monthAfter (6 - lastWeekDay)

        tomorrow wDay =
            remainderBy 7 (wDay + 1)

        appendDay : Int -> SDay -> List (List SDay) -> List (List SDay)
        appendDay wDay sDay constructedWeeks =
            let
                res =
                    case constructedWeeks of
                        [] ->
                            [ [ sDay ] ]

                        prevWeek :: rest ->
                            if wDay == 0 then
                                [ sDay ] :: constructedWeeks

                            else
                                (sDay :: prevWeek) :: rest
            in
            if sDay == lastDay then
                res

            else
                appendDay (tomorrow wDay) (nextDay sDay) res

        reversedAll =
            appendDay 0 firstDay []

        reversedWeeks =
            List.map List.reverse reversedAll
    in
    List.reverse reversedWeeks


defaultDay : SDay
defaultDay =
    SDay (SMonth (SYear 1970) 1) 1
