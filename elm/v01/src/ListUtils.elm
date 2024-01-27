module ListUtils exposing (changeIndex, removeIndex)


removeIndex : Int -> List a -> List a
removeIndex index list =
    let
        fn a ( i, res ) =
            if i == index then
                ( i + 1, res )

            else
                ( i + 1, a :: res )

        ( len, reversed ) =
            List.foldl fn ( 0, [] ) list
    in
    List.reverse reversed


changeIndex : (a -> a) -> Int -> List a -> List a
changeIndex fn index list =
    let
        mapper i item =
            if i == index then
                fn item

            else
                item
    in
    List.indexedMap mapper list
