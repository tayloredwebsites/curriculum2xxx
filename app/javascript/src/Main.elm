module Main exposing (..)
import Http
import Html exposing (Html, h1, div, text, program)
import Models exposing (Model, initialModel, Translation)
import Msgs exposing (Msg)
import Translations.Listing exposing (nav, list)
-- commands import
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)
import RemoteData exposing (WebData)

-- INIT

init : (Model, Cmd Msg)
init =
  (initialModel, fetchTranslations) --, Cmd.none) --

-- VIEW

view : Model -> Html Msg
view model =
  -- The inline style is being used for example purposes in order to keep this example simple and
  -- avoid loading additional resources. Use a proper stylesheet when building your own app.
  -- h1 [style [("display", "flex"), ("justify-content", "center")]]
  --    [ text "Hello Elm!" ]
  div []
    [ page model
    ]

page: Model -> Html Msg
page model =
  Translations.Listing.view model.translations

-- MESSAGE (see Msgs.elm)

-- UPDATE

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Msgs.OnFetchTranslations response ->
      ({ model | translations = response}, Cmd.none)

-- COMMANDS

fetchTranslations : Cmd Msg
fetchTranslations =
  Http.get fetchTranslationsUrl translationsDecoder
  |> RemoteData.sendRequest
  |> Cmd.map Msgs.OnFetchTranslations

fetchTranslationsUrl : String
fetchTranslationsUrl =
  "http://localhost:5000/translations.json"

translationsDecoder : Decode.Decoder (List Translation)
translationsDecoder =
  Decode.list translationDecoder

translationDecoder : Decode.Decoder Translation
translationDecoder =
  decode Translation
    |> required "id" Decode.int
    |> required "locale" Decode.string
    |> required "key" Decode.string
    |> required "value" Decode.string


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
