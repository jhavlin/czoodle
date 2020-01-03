module VotePage exposing (main)

import Browser
import Json.Decode as D
import Vote.VoteModel exposing (Model, Msg)
import Vote.VoteUpdate exposing (init, subscriptions, update)
import Vote.VoteView exposing (view)


main : Program D.Value Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
