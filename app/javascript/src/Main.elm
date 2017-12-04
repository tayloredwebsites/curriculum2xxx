module Main exposing (..)

import Html exposing (Html, h1, div, text, program)
import Html.Attributes exposing (style)
import Models exposing (Model, initialModel)
import Msgs exposing (Msg)

import Translations.Listing

-- INIT

init : (Model, Cmd Msg)
init =
  (initialModel, Cmd.none)

-- VIEW

view : Model -> Html Msg
view model =
  -- The inline style is being used for example purposes in order to keep this example simple and
  -- avoid loading additional resources. Use a proper stylesheet when building your own app.
  -- h1 [style [("display", "flex"), ("justify-content", "center")]]
  --    [text "Hello Elm!"]
  div []
    [page model]

page: Model -> Html Msg
page model =
  Translations.Listing.view model.translations

-- MESSAGE (see Msgs.elm)

-- UPDATE

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  (model, Cmd.none)

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

-- MAIN

main : Program Never Model Msg
main =
  Html.program
    {
      init = init,
      view = view,
      update = update,
      subscriptions = subscriptions
    }
