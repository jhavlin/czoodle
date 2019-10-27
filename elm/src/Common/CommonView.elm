module Common.CommonView exposing (onChange)

import Html
import Html.Events exposing (on)
import Html.Keyed
import Html.Lazy exposing (lazy)
import Json.Decode as D



-- Wrap text into span and a lazy keyed node to try prevenion of some problems when the DOM
-- is modified extenrally, e.g. by automatic translation or a browser extension.
-- But in practice this didn't prove to work.


safeText : String -> Html.Html a
safeText str =
    Html.Keyed.node "span" [] [ ( str, Html.span [] [ lazy (\a -> Html.text a) str ] ) ]


onChange : (String -> msg) -> Html.Attribute msg
onChange handler =
    on "change" <| D.map handler <| D.at [ "target", "value" ] D.string
