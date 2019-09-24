module Common.CommonView exposing (safeText)

import Html
import Html.Keyed
import Html.Lazy exposing (lazy)



-- Wrap text into span and a lazy keyed node to try prevenion of some problems when the DOM
-- is modified extenrally, e.g. by automatic translation or a browser extension.
-- But in practice this didn't prove to work.


safeText : String -> Html.Html a
safeText str =
    Html.Keyed.node "span" [] [ ( str, Html.span [] [ lazy (\a -> Html.text a) str ] ) ]
