module Common.ListUtils exposing
    ( changeIndex
    , filterNothings
    , findFirst
    , removeIndex
    )


removeIndex : Int -> List a -> List a
removeIndex index list =
    let
        fn a ( i, res ) =
            if i == index then
                ( i + 1, res )

            else
                ( i + 1, a :: res )

        ( _, reversed ) =
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


filterNothings : List (Maybe a) -> List a
filterNothings list =
    List.foldr
        (\curr acc ->
            case curr of
                Just a ->
                    a :: acc

                Nothing ->
                    acc
        )
        []
        list


findFirst : (a -> Bool) -> List a -> Maybe a
findFirst predicate list =
    let
        fn curr acc =
            case acc of
                Nothing ->
                    if predicate curr then
                        Just curr

                    else
                        Nothing

                Just _ ->
                    acc
    in
    List.foldl fn Nothing list
