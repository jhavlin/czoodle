module CreatePage exposing (main)

import Browser
import Create.CreateModel exposing (Model, Msg)
import Create.CreateUpdate exposing (init, subscriptions, update)
import Create.CreateView exposing (view)
import Json.Decode as D


main : Program D.Value Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
