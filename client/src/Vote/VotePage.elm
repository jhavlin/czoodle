module Vote.VotePage exposing (main)

import Browser
import Vote.VoteModel exposing (Model)
import Vote.VoteUpdate exposing (Msg, init, subscriptions, update)
import Vote.VoteView
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
    , body = [Vote.VoteView.view model]
    }
