module Create.CreatePage exposing (main)
import Browser
import Create.CreateModel exposing (Model, Msg)
import Create.CreateUpdate exposing (init, subscriptions, update)
import Create.CreateView
import Json.Decode as D

main : Program D.Value Model Msg
main =
    Browser.document
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }

view: Model -> Browser.Document Msg
view model =
    { title = "Czoodle" -- TODO
    , body = [Create.CreateView.view model]
    }
