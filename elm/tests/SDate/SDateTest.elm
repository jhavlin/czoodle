module SDate.SDateTest exposing (suite)

import Expect
import Maybe exposing (Maybe, andThen, map)
import SDate.SDate exposing (dayFromTuple, dayToTuple, daysInMonth, monthFromTuple, weekDay, weeksInMonth)
import Test exposing (Test, describe, test)



-- Helper functions


monthDays : Int -> Int -> Maybe Int
monthDays year month =
    monthFromTuple ( year, month )
        |> map (\m -> daysInMonth m)


day : Int -> Int -> Int -> Maybe ( Int, Int, Int )
day y m d =
    dayFromTuple ( y, m, d ) |> Maybe.map dayToTuple


wDay : Int -> Int -> Int -> Maybe Int
wDay y m d =
    dayFromTuple ( y, m, d ) |> Maybe.map weekDay



-- Actual tests


suite : Test
suite =
    describe "SDate"
        [ describe "SDate.daysInMonth"
            [ test "Janury 1989" <|
                \_ -> Expect.equal (Just 31) (monthDays 1989 1)
            , test "February 1970" <|
                \_ -> Expect.equal (Just 28) (monthDays 1970 2)
            , test "February 1998" <|
                \_ -> Expect.equal (Just 28) (monthDays 1998 2)
            , test "February 2000" <|
                \_ -> Expect.equal (Just 29) (monthDays 2000 2)
            , test "February 2004" <|
                \_ -> Expect.equal (Just 29) (monthDays 2004 2)
            , test "February 2100" <|
                \_ -> Expect.equal (Just 28) (monthDays 2100 2)
            , test "March 2022" <|
                \_ -> Expect.equal (Just 31) (monthDays 2022 3)
            , test "April 2022" <|
                \_ -> Expect.equal (Just 30) (monthDays 2022 4)
            , test "May 2022" <|
                \_ -> Expect.equal (Just 31) (monthDays 2022 5)
            , test "June 2022" <|
                \_ -> Expect.equal (Just 30) (monthDays 2022 6)
            , test "July 2022" <|
                \_ -> Expect.equal (Just 31) (monthDays 2022 7)
            , test "August 2022" <|
                \_ -> Expect.equal (Just 31) (monthDays 2022 8)
            , test "September 2022" <|
                \_ -> Expect.equal (Just 30) (monthDays 2022 9)
            , test "October 2022" <|
                \_ -> Expect.equal (Just 31) (monthDays 2022 10)
            , test "November 2022" <|
                \_ -> Expect.equal (Just 30) (monthDays 2022 11)
            , test "December 2022" <|
                \_ -> Expect.equal (Just 31) (monthDays 2022 12)
            ]
        , describe "SDate.dayFromTuple"
            [ test "Date 2019-03-21" <|
                \_ -> Expect.equal (Just ( 2019, 3, 21 )) (day 2019 3 21)
            , test "Date 2019-00-21" <|
                \_ -> Expect.equal Nothing (day 2019 0 21)
            , test "Date 2019-19-21" <|
                \_ -> Expect.equal Nothing (day 2019 13 21)
            , test "Date 2019-03-00" <|
                \_ -> Expect.equal Nothing (day 2019 3 0)
            , test "Date 2019-03-32" <|
                \_ -> Expect.equal Nothing (day 2019 3 32)
            , test "Date 2019-02-29" <|
                \_ -> Expect.equal Nothing (day 2019 2 29)
            , test "Date 2100-02-29" <|
                \_ -> Expect.equal Nothing (day 2100 2 29)
            , test "Date 2000-04-29" <|
                \_ -> Expect.equal (Just ( 2000, 4, 29 )) (day 2000 4 29)
            , test "Date 2022-05-31" <|
                \_ -> Expect.equal (Just ( 2022, 5, 31 )) (day 2022 5 31)
            , test "Date 2022-06-30" <|
                \_ -> Expect.equal (Just ( 2022, 6, 30 )) (day 2022 6 30)
            , test "Date 2022-07-31" <|
                \_ -> Expect.equal (Just ( 2022, 7, 31 )) (day 2022 7 31)
            , test "Date 2022-08-31" <|
                \_ -> Expect.equal (Just ( 2022, 8, 31 )) (day 2022 8 31)
            ]
        , describe "SDate.weekDay"
            [ test "Weekday 1900-01-01" <|
                \_ -> Expect.equal (Just 0) (wDay 1900 1 1)
            , test "Weekday 1904-01-01" <|
                \_ -> Expect.equal (Just 4) (wDay 1904 1 1)
            , test "Weekday 1905-01-01" <|
                \_ -> Expect.equal (Just 6) (wDay 1905 1 1)
            , test "Weekday 1906-01-01" <|
                \_ -> Expect.equal (Just 0) (wDay 1906 1 1)
            , test "Weekday 2000-01-01" <|
                \_ -> Expect.equal (Just 5) (wDay 2000 1 1)
            , test "Weekday 2001-01-01" <|
                \_ -> Expect.equal (Just 0) (wDay 2001 1 1)
            , test "Weekday 1900-01-02" <|
                \_ -> Expect.equal (Just 1) (wDay 1900 1 2)
            , test "Weekday 1900-01-03" <|
                \_ -> Expect.equal (Just 2) (wDay 1900 1 3)
            , test "Weekday 1900-02-01" <|
                \_ -> Expect.equal (Just 3) (wDay 1900 2 1)
            , test "Weekday 1900-02-28" <|
                \_ -> Expect.equal (Just 2) (wDay 1900 2 28)
            , test "Weekday 1900-03-01" <|
                \_ -> Expect.equal (Just 3) (wDay 1900 3 1)
            , test "Weekday 2000-03-01" <|
                \_ -> Expect.equal (Just 2) (wDay 2000 3 1)
            , test "Weekday 2001-01-02" <|
                \_ -> Expect.equal (Just 1) (wDay 2001 1 2)
            , test "Weekday 2001-03-01" <|
                \_ -> Expect.equal (Just 3) (wDay 2001 3 1)
            , test "Weekday 2004-02-29" <|
                \_ -> Expect.equal (Just 6) (wDay 2004 2 29)
            , test "Weekday 2004-03-01" <|
                \_ -> Expect.equal (Just 0) (wDay 2004 3 1)
            , test "Weekday 2004-12-31" <|
                \_ -> Expect.equal (Just 4) (wDay 2004 12 31)
            , test "Weekday 2019-03-23" <|
                \_ -> Expect.equal (Just 5) (wDay 2019 3 23)
            ]
        , describe "SDate.weeksInMonth"
            [ test "Weeks in month March 2019" <|
                \_ ->
                    let
                        sMonth =
                            monthFromTuple ( 2019, 3 )

                        weeks =
                            Maybe.map weeksInMonth sMonth

                        count =
                            Maybe.map List.length weeks

                        flat =
                            Maybe.map List.concat weeks

                        dayCount =
                            Maybe.map List.length flat

                        reversed =
                            Maybe.map List.reverse flat

                        first =
                            Maybe.andThen List.head flat |> Maybe.map dayToTuple

                        last =
                            Maybe.andThen List.head reversed |> Maybe.map dayToTuple
                    in
                    Expect.all
                        [ \_ -> Expect.equal (Just 5) count
                        , \_ -> Expect.equal (Just 35) dayCount
                        , \_ -> Expect.equal (Just ( 2019, 2, 25 )) first
                        , \_ -> Expect.equal (Just ( 2019, 3, 31 )) last
                        ]
                        ()
            ]
        ]
