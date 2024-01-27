module Common.CommonView exposing
    ( changedToClass
    , editableToClass
    , invisibleToClass
    , onChange
    , optClass
    , transparentToClass
    , viewBoxInfo
    )

import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Html.Events exposing (on)
import Json.Decode as D



-- Wrap text into span and a lazy keyed node to try prevenion of some problems when the DOM
-- is modified extenrally, e.g. by automatic translation or a browser extension.
-- But in practice this didn't prove to work.


viewBoxInfo : String -> Html msg
viewBoxInfo string =
    div
        [ class "box-info" ]
        [ div [ class "box-info-icon" ] [ text "i" ]
        , div [ class "box-info-text" ] [ text string ]
        ]


onChange : (String -> msg) -> Html.Attribute msg
onChange handler =
    on "change" <| D.map handler <| D.at [ "target", "value" ] D.string


optClass : Bool -> String -> String
optClass present name =
    if present then
        " " ++ name

    else
        ""


changedToClass : Bool -> String
changedToClass changed =
    if changed then
        " changed"

    else
        ""


editableToClass : Bool -> String
editableToClass editable =
    if editable then
        " editable"

    else
        ""


invisibleToClass : Bool -> String
invisibleToClass invisible =
    if invisible then
        " invisible"

    else
        ""


transparentToClass : Bool -> String
transparentToClass transparent =
    if transparent then
        " transparent"

    else
        ""
